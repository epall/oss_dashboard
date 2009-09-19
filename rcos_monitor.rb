# rcos_monitor.rb
# A Sinatra application for monitoring the status of RCOS projects

require 'rubygems'
require 'sinatra'
require 'erb'
require 'simple-rss'
require 'open-uri'
require 'feed_detector'

SECONDS_IN_DAY = 60 * 60 * 24

def repo_update(repo_info)
    last_update(repo_info['URL']) if ['github', 'Google Code'].include? repo_info['Type']
end

def repo_age(repo_info)
    case(repo_info['Type'])
    when 'github' then blog_age(repo_info['URL'])
    when 'Google Code' then blog_age(repo_info['URL'])
    else raise "Repository type not supported: #{repo_info['Type']}"
    end
end

def render_source_code(project)
    return "<a href=\"#{project['Source Code']}\">Yes</a>" unless project['Repo']
    if ['github', 'Google Code'].include? project['Repo']['Type']
        "<a href=\"#{project['Source Code']}\">#{project['Repo']['Type']}</a> (#{repo_update(project['Repo'])})"
    else "<a href=\"#{project['Source Code']}\">Yes</a>"
    end
end

def fetch_blog(blog_url)
    @blog_cache ||= {}
    rss = @blog_cache[blog_url]
    unless rss
        feed_url = FeedDetector.fetch_feed_url(blog_url)
        rss = SimpleRSS.parse open(feed_url)
        @blog_cache[blog_url] = rss
    end
    return rss
end

def last_update(blog_url)
    published = fetch_blog(blog_url).entries.first.published
    published ||= fetch_blog(blog_url).entries.first.updated 
    published.strftime('%m/%d')
end

def blog_age(blog_url)
    published = fetch_blog(blog_url).entries.first.published
    published ||= fetch_blog(blog_url).entries.first.updated 
    age = Time.now - published
    days_old = (age / SECONDS_IN_DAY)
    return days_old
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
            "<a href=\"#{value}\">Yes</a> (#{last_update(value)})"
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
            value.join('\n<br>\n')
        else
            value
        end
    end
    
    def value_class(col_name, project)
        value = project[col_name]
        unless ['Project Name', 'Contributors', 'Website'].include? col_name
            return 'no' if value.nil?
            if col_name == 'Blog'
                return blog_age(value) > BLOG_STALE_AGE ? 'stale' : 'yes'
            elsif col_name == 'Source Code'
                if project['Repo']
                    return repo_age(project['Repo']) > CODE_STALE_AGE ? 'stale' : 'yes'
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
        if col_name == 'Blog'
            return color_from_age(blog_age(project[col_name]))
        elsif col_name == 'Source Code' && project['Repo']
            return color_from_age(repo_age(project['Repo']))
        else
            return ''
        end
    end
end

get '/' do
    headers['Cache-Control'] = 'public, max-age=3600'
    @columns = ['Project Name', 'Contributors', 'Blog', 'Source Code', 'Wiki']
    @projects = YAML.load(File.open('projects.yml'))
    erb :index
end

get '/colordemo' do
    erb :colordemo
end
