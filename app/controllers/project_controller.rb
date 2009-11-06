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
  end

  def create
  end

  def update
  end

  def approve
  end

  def new
  end

  def edit
  end
end
