class EventsController < ApplicationController
  layout 'simple'
  def index
    @events = Event.blog.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 10
  end
end
