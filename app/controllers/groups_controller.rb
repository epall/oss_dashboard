class GroupsController < ApplicationController
  caches_page :show, :dashboard, :feed
  layout 'application', :except => [:show]
  
  def index
    # TODO actually support listing of groups
    if Group.count.zero?
      redirect_to :action => :new
    else
      redirect_to :action => :dashboard, :id => Group.last.id
    end
  end
  
  def show
    @group = Group.find(params[:id])
  end
  
  def dashboard
    @group = Group.find(params[:id])

    @projects = @group.projects.approved.sort_by(&:age)
    
    # generate statistics
    @stats = {}
    @stats['num_projects'] = @projects.size
    @stats['none'] = @projects.reject{|p| p.blog || p.wiki || p.source_code}.size
    @stats['all_three'] = @projects.select{|p| p.blog && p.wiki && p.source_code}.size
    @stats['last_week'] = @projects.select{|p| [p.blog_age, p.source_code_age].min < 7}.size
    @stats['members'] =  @projects.map(&:contributors).map{|c| c.split(/, ?/)}.flatten.uniq.size
  end

  def admin
    @group = Group.find(params[:id], :include => [:projects])
  end
  
  def fetch
    @group = Group.find(params[:id])
    @group.fetch
    expire_page :action => :show, :id => @group.id
    expire_page :action => :feed, :id => @group.id
    expire_page :action => :dashboard, :id => @group.id
    redirect_to :action => :dashboard, :id => @group.id
  end
  
  def laggards
    @group = Group.find(params[:id], :include => [:projects])
    @projects = @group.projects.find_all do |project|
      project.blog_age > 14 || project.source_code_age > 14
    end
  end
  
  def authenticate
    @group = Group.find(params[:id])
    if request.post?
      if params[:admin_password] == @group.admin_password
        session[:admin_for_groups] ||= []
        session[:admin_for_groups] << @group.id
        @next = true
      else
        flash[:notice] = "Access denied"
        redirect_to :back
      end
    end
  end
  
  def feed
    @group = Group.find(params[:id])
    @events = @group.events.paginate :page => params[:page], :per_page => 10
    
    respond_to do |format|
      format.html
      format.atom
    end
  end
end
