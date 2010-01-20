class GroupController < ApplicationController
  layout 'application', :except => 'show'

  def index
    # TODO actually support listing of groups
    redirect_to :action => 'show', :id => Group.first.id
  end

  def show
    @group = Group.find(params[:id])

    @projects = @group.projects.approved.sort_by(&:age)
    
    # generate statistics
    @stats = {}
    @stats['num_projects'] = @projects.size
    @stats['none'] = @projects.reject{|p| p.blog || p.wiki || p.source_code}.size
    @stats['all_three'] = @projects.select{|p| p.blog && p.wiki && p.source_code}.size
    @stats['last_week'] = @projects.select{|p| p.age < 7}.size
  end

  def admin
    @group = Group.find(params[:id], :include => [:projects])
  end
end
