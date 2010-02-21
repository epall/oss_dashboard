class EventsController < ApplicationController
  caches_page :index, :full
  
  def index
    @events = Event.blog.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 10, :include => [:project]
    respond_to do |format|
      format.html
      format.atom
    end
  end
  def full
    @event = Event.find(params[:id]) rescue redirect_to(:action => :index) if @event == nil
  end
end
