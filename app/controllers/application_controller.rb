# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  private
  
  def expire_dynamic_pages(group)
    expire_page :controller => :groups, :action => :show, :id => group.id
    expire_page :controller => :groups, :action => :feed, :id => group.id
    1.upto(10) do |n|
      expire_page :controller => :groups, :action => :feed, :id => group.id, :page => n
    end
    expire_page :controller => :groups, :action => :dashboard, :id => group.id
  end
end
