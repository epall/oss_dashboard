# rcos_monitor.rb
# A Sinatra application for monitoring the status of RCOS projects

require 'rubygems'
require 'sinatra'
require 'erb'
require 'simple-rss'
require 'open-uri'
require 'feed_detector'

SECONDS_IN_DAY = 60 * 60 * 24

helpers do
    def render_column(col_name, value)
        return 'No' if value.nil?
        if col_name == 'Blog'
            "<a href=\"#{value}\">Yes</a> (#{last_update(value)})"
        elsif value.is_a? String and value.match(/http/)
            "<a href=\"#{value}\">Yes</a>"
        elsif value.is_a? Array
            value.join('\n<br>\n')
        else
            value
        end
    end

    def value_style(col_name, value)
        unless ['Name', 'Contributors', 'Website'].include? col_name
            return 'no' if value.nil?

            if col_name == 'Blog'
                if blog_age(value) > 7
                    return 'stale'
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
        fetch_blog(blog_url).entries.first.published.strftime('%m/%d')
    end

    def blog_age(blog_url)
        rss = fetch_blog(blog_url)
        age = Time.now - rss.entries.first.published
        days_old = (age / SECONDS_IN_DAY)
        return days_old
    end
end

get '/' do
    @columns = ['Name', 'Contributors', 'Website', 'Blog', 'Wiki', 'Source Code']
    @projects = YAML.load(File.open('projects.yml'))
    erb :index
end
