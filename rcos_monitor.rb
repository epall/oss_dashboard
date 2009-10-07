# rcos_monitor.rb
# A Sinatra application for monitoring the status of RCOS projects

require 'rubygems'
require 'sinatra'
require 'erb'
require 'simple-rss'
require 'open-uri'
require 'feed_detector'
require 'yaml'
require 'timeout'
require 'feedzirra'
require 'activerecord'

SECONDS_IN_DAY = 60 * 60 * 24
COLUMNS = ['Project Name', 'Contributors', 'Blog', 'Source Code', 'Wiki']
RSS_ENABLED_REPOSITORIES = ['github', 'Google Code', 'bitbucket', 'cgit', 'Redmine', 'Trac']

 
dbconfig = YAML.load(File.read('config/database.yml'))
ActiveRecord::Base.establish_connection dbconfig['production']

class BlogToRss < ActiveRecord::Base
        set_table_name "blog_to_rss"
end

class BlogFailError < StandardError
end

def get_feed_url(blog_url)
        db_cache = BlogToRss.find(:first, :conditions => {:blog_url => blog_url})
        return db_cache.feed_url if db_cache

        puts "Initializing feed url for #{blog_url}"
        feed_url = FeedDetector.fetch_feed_url(blog_url)
        BlogToRss.create(:blog_url => blog_url, :feed_url => feed_url).save!
        return feed_url
end

def fetch_all_blogs(projects)
    urls = projects.reject{|p| p['Blog'].nil?}.map{|p| p['Blog'].is_a?(String) ? p['Blog'] : p['Blog']['Feed']}.map{|u| get_feed_url(u)}
    urls += projects.map do |project|
            if project['Repo'] && RSS_ENABLED_REPOSITORIES.include?(project['Repo']['Type'])
                    get_feed_url(project['Repo']['URL'])
            else
                    nil
            end

    end.reject{|u| u.nil?}
    puts "Feedzirra GO"
    @feed_cache = Feedzirra::Feed.fetch_and_parse(urls, {:timeout => 20})
    puts "Feedzirra DONE"
end

# Fetch an RSS/Atom feed from a blog URL. Automatically detects the feed link
# using FeedDetector and caches results for duration of this HTTP request.
def fetch_blog(blog_url)
    blog_url = blog_url['Feed'] unless blog_url.is_a? String
    feed = @feed_cache[get_feed_url(blog_url)]
    if feed.is_a? Fixnum
        raise BlogFailError, blog_url
    else
        return feed
    end
end

# different blog engines use different RSS fields to specifiy when an entry
# was published. This method evens that all out so you always get a DateTime
# for when the most recent entry was updated.
def publish_time(blog_url)
    begin
        entry = fetch_blog(blog_url).entries.first
        return nil if entry.nil?
        return entry.updated || entry.published || entry.pubDate
    end
end

# Get the date of the last update to the given blog in the format mm/dd
def last_update(blog_url)
    begin
        published = publish_time(blog_url)
        return 'No updates' if published.nil?
        return published.strftime('%m/%d')
    rescue BlogFailError
        return 'Down or slow'
    end
end

# Get the age of the last update to the given blog in days. Returns a
# floating point value.
def blog_age(blog_url)
    published = nil
    begin
        published = publish_time(blog_url)
    rescue BlogFailError
        return 100
    end
    return 100 unless published
    age = Time.now - published
    days_old = (age / SECONDS_IN_DAY)
    return days_old
end

# Gets date of last update to repository or nil if it's not a known type
def repo_update(repo_info)
    last_update(repo_info['URL']) if RSS_ENABLED_REPOSITORIES.include? repo_info['Type']
end

# Gets age of last update to repository in days. Throws an exception if
# repository is of an unknown type.
def repo_age(repo_info)
    if RSS_ENABLED_REPOSITORIES.include? repo_info['Type']
        blog_age(repo_info['URL'])
    elsif repo_info['Type'] == 'git' || repo_info['Type'] == 'GNOME'
        return 100
    else
        raise "Repository type not supported: #{repo_info['Type']}"
    end
end

# Render the source code column of the display, including links to the code
# and date of last update.
def render_source_code(project)
    return "<a href=\"#{project['Source Code']}\">Yes</a>" unless project['Repo']
    if RSS_ENABLED_REPOSITORIES.include? project['Repo']['Type']
        "<a href=\"#{project['Source Code']}\">#{project['Repo']['Type']}</a> (#{repo_update(project['Repo'])})"
    elsif project['Repo']['Type'] == 'git'
        "<a href=\"#{project['Source Code']}\">git</a> (Unavailable)"
    else
        "<a href=\"#{project['Source Code']}\">Yes</a>"
    end
end

# Given an array of projects, rank them from most recently updated to least
# recently updated.
def rank_by_age(projects)
    projects.sort_by do |project|
        score = 0
        score += 1000 unless project['Source Code']
        score += 1000 unless project['Blog']
        score += 1000 unless project['Wiki']
        if project['Repo']
            if project['Blog']
                score += [repo_age(project['Repo']), blog_age(project['Blog'])].min
            else
                score += repo_age(project['Repo'])
            end
        elsif project['Blog']
            score += blog_age(project['Blog'])
        end
        score
    end
end

helpers do
    def color_from_age(days_old)
        green = red = 0
        if days_old < 15
            green = 255
            red = 255.0*(1.0 - 1.20**-days_old)
        elsif days_old < 30
            red = 255
            green = 255.0*(1.08**(15-days_old))
        else
            red = 255
            green = 80
        end
        return 'background-color:#'+sprintf('%02x', red.to_i)+sprintf('%02x', green)+'00;'
    end

    def render_column(col_name, project)
        value = project[col_name]
        return 'No' if value.nil?
        if col_name == 'Blog'
            if value.is_a? String
                "<a href=\"#{value}\">Yes</a> (#{last_update(value)})"
            else
                "<a href=\"#{value['Web']}\">Yes</a> (#{last_update(value)})"
            end
        elsif col_name == 'Source Code'
            render_source_code(project)
        elsif col_name == 'Project Name'
            if project['Website'].nil?
                value
            else
                "<a href=\"#{project['Website']}\">#{value}</a>"
            end
        elsif value.is_a? String and value.match(/http/)
            "<a href=\"#{value}\">Yes</a>"
        elsif value.is_a? Array
            value.join("\n<br>\n")
        else
            value
        end
    end
    
    def value_class(col_name, project)
        value = project[col_name]
        unless ['Project Name', 'Contributors', 'Website'].include? col_name
            return 'no' if value.nil?
            if col_name == 'Blog'
                return ''
            elsif col_name == 'Source Code'
                if project['Repo']
                    return ''
                else
                    return 'yes'
                end
            else
                return 'yes'
            end
        end
        ''
    end

    def value_style(col_name, project)
        if col_name == 'Blog' && project['Blog']
            return color_from_age(blog_age(project[col_name]))
        elsif col_name == 'Source Code' && project['Repo']
            return color_from_age(repo_age(project['Repo']))
        else
            return ''
        end
    end
end

get '/' do
    headers['Cache-Control'] = "public, max-age=#{60 * 60 * 6}"
    raw_projects = YAML.load(File.open('projects.yml'))
    fetch_all_blogs(raw_projects)
    @projects = rank_by_age(raw_projects)
    erb :index
end

get '/key' do
    erb :colordemo
end
