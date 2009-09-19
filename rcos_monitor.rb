# rcos_monitor.rb
# A Sinatra application for monitoring the status of RCOS projects

require 'rubygems'
require 'sinatra'
require 'erb'
helpers do
    def render_column(col_name, value)
        return 'No' if value.nil?
        if value.is_a? String and value.match(/http/)
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
            return 'yes'
        end
        ''
    end
end

get '/' do
    @columns = ['Name', 'Contributors', 'Website', 'Blog', 'Wiki', 'Source Code']
    @projects = YAML.load(File.open('projects.yml'))
    erb :index
end
