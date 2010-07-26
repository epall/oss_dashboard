class GroupsController < ApplicationController
  caches_page :dashboard, :feed
  caches_action :show # action caching to separate by subdomain
  layout 'application', :except => [:show, :index]
  
  def index
    @groups = Group.all(:order => "created_at DESC")

    if request.host == 'dashboard.rcos.cs.rpi.edu'
      @group = @groups.first
      dashboard # setup template parameters
      render :action => :dashboard, :id => @groups.first, :layout => 'application'
    else
      render
    end
  end
  
  def show
    @group = Group.find(params[:id], :include => [:projects])
    respond_to do |format|
      format.html
      format.json { render :json => @group }
    end
  end
  
  def dashboard
    @group ||= Group.find(params[:id])

    @projects = @group.projects.approved.sort_by(&:age)
    
    # generate statistics
    @stats = {}
    @stats['num_projects'] = @projects.size
    @stats['none'] = @projects.reject{|p| p.blog || p.wiki || p.source_code}.size
    @stats['all_three'] = @projects.select{|p| p.blog && p.wiki && p.source_code}.size
    @stats['last_week'] = @projects.select{|p| [p.blog_age, p.source_code_age].min < 7}.size
    @stats['members'] =  @projects.map(&:contributors).map{|c| (c || "").split(/, ?/)}.flatten.uniq.size
  end

  def admin
    classB = request.remote_ip.split('.')[0..1].join('.')
    if classB == '128.113' or classB == '128.213' or classB == '129.161' or classB == '127.0'
      @group = Group.find(params[:id], :include => [:projects])
    else
      flash[:notice] = "Access restricted to RPI IP addresses"
      redirect_to :action => :dashboard, :id => params[:id]
    end
  end
  
  def fetch
    @group = Group.find(params[:id])
    @group.fetch
    expire_dynamic_pages(@group)
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
