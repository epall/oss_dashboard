class ProjectController < ApplicationController
  layout 'application', :except => :index
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
    @project ||= Project.new
    @project.update_attributes!(params[:project])

    case params[:hosting]
    when 'Redmine'
      @project.source_code = params['redmine'].sub('projects/show', 'repositories/show')
      @project.source_code_feed = @project.source_code.sub('repositories/show', 'repositories/revisions')+'?format=atom'
    when 'GitHub'
      member, project = params['github'].split('/')
      @project.source_code = "http://github.com/#{member}/#{project}"
      @project.source_code_feed = "http://github.com/feeds/#{member}/commits/#{project}/master"
    when 'Google Code'
      project_name = params['googlecode']
      @project.source_code = "http://code.google.com/p/#{project_name}/source/browse/"
      @project.source_code_feed = "http://code.google.com/feeds/p/#{project_name}/svnchanges/basic"
    else
      raise "Unrecognized hosting type"
    end
    @project.save!

    redirect_to :action => :index
  end

  def approve
  end

  def new
    @project = Project.new
    render :action => 'edit'
  end

  def edit
    @project = Project.find(params[:id])
  end
end
