class ProjectController < ApplicationController
  def index
    @projects = Project.fetch
    
    # generate statistics
    @stats = {}
    @stats['num_projects'] = @projects.size
    @stats['none'] = @projects.reject{|p| p.blog || p.wiki || p.source_code}.size
    @stats['all_three'] = @projects.select{|p| p.blog && p.wiki && p.source_code}.size
    @stats['last_week'] = @projects.select{|p| p.age < 7}.size

    @legit_coumns = Project.columns.find_all{|c| c.type == :string}.map(&:name).map{|name| name.gsub('_', ' ').capitalize} - ['Password', 'Blog feed', 'Source code feed', 'Website']

    expires_in 1.hour, :public => true
  end

  def create
  end

  def update
    if ENV['ADMIN_PASSWORD'] != params[:admin_password]
      flash[:notice] = "Access denied"
      redirect_to :back
      return
    end

    @project = Project.find(params[:id])
    @project.update_attributes!(params[:project])

    redirect_to :action => :index
  end

  def approve
  end

  def new
    @project = Project.new
  end

  def edit
    @project = Project.find(params[:id])
  end
end
