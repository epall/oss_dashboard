# rcos_monitor.rb
# A Sinatra application for monitoring the status of RCOS projects

require 'rubygems'
require 'sinatra'
require 'erb'

get '/' do
    erb :index
end
