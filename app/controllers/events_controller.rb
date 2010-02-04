class EventsController < ApplicationController
  def index
    @events = Event.blog.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 10
    respond_to do |format|
      format.html
      format.atom
    end
  end
end
