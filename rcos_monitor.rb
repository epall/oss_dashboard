# rcos_monitor.rb
# A Sinatra application for monitoring the status of RCOS projects

require 'rubygems'
require 'sinatra'
require 'erb'
require 'simple-rss'
require 'open-uri'
require 'feed_detector'

SECONDS_IN_DAY = 60 * 60 * 24
BLOG_STALE_AGE = 14
CODE_STALE_AGE = 14

helpers do
    def render_column(col_name, project)
        value = project[col_name]
        return 'No' if value.nil?
        if col_name == 'Blog'
            "<a href=\"#{value}\">Yes</a> (#{last_update(value)})"
        elsif col_name == 'Source Code'
            render_source_code(project)
        elsif value.is_a? String and value.match(/http/)
            "<a href=\"#{value}\">Yes</a>"
        elsif value.is_a? Array
            value.join('\n<br>\n')
        else
            value
        end
    end

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
    
    def value_style(col_name, project)
        value = project[col_name]
        unless ['Name', 'Contributors', 'Website'].include? col_name
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
end

get '/' do
    @columns = ['Name', 'Contributors', 'Website', 'Blog', 'Wiki', 'Source Code']
    @projects = YAML.load(File.open('projects.yml'))
    erb :index
end
