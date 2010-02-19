class GroupController < ApplicationController
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
    @stats['last_week'] = @projects.select{|p| [p.blog_age, p.source_code_age].min < 7}.size
    @stats['members'] =  @projects.map(&:contributors).map{|c| c.split(/, ?/)}.flatten.uniq.count
  end

  def admin
    @group = Group.find(params[:id], :include => [:projects])
  end
end
