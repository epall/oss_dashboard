class ProjectsController < ApplicationController
  layout 'application', :except => [:new]

  def create
    @project = Project.new(params[:project])
    @project.group = Group.last
    @project.password = generate_password
    @project.approved = false
    @project.save!
  end

  def update
    @project = Project.find(params[:id])
    session[:admin_for_groups] ||= []
    if @project.group.admin_password == params[:password]
      session[:admin_for_groups] << @project.group.id
    end
    
    unless session[:admin_for_groups].include?(@project.group.id) or @project.password == params[:password]
      flash[:notice] = "Incorrect password"
      redirect_to :back
      return
    end

    @project.update_attributes!(params[:project])
    
    expire_dynamic_pages(@project.group)

    redirect_to :controller => 'groups', :action => 'show', :id => @project.group
  end

  ## Page that allows user to confirm deletion of their project
  def delete_confirm
    @project = Project.find(params[:id])
  end

  ## Actual deletion of a project
  def delete
    @project = Project.find(params[:id])
    session[:admin_for_groups] ||= []
    if @project.group.admin_password == params[:password]
      session[:admin_for_groups] << @project.group.id
    end

    unless session[:admin_for_groups].include?(@project.group.id) or @project.password == params[:password]
      flash[:notice] = "Incorrect password"
      redirect_to :back
      return
    end

    group = @project.group


    ## Delete project
    @project.destroy()

    expire_dynamic_pages(group)

    redirect_to :controller => 'groups', :action => 'show', :id => group
  end

  def approve
    @project = Project.find(params[:id], :include => [:group])
    if request.method == :post
      if params[:admin_password] == @project.group.admin_password
        @project.update_attribute('approved', true)
        redirect_to :controller => :groups, :action => :fetch, :id => @project.group.id
      else
      flash[:notice] = "Access denied"
      redirect_to :back
      end
    end
  end
  
  def add_presentation
    @project = Project.find(params[:id], :include => [:group])
    if request.post?
      if session[:admin_for_groups] and session[:admin_for_groups].include?(@project.group.id)
        @project.presentation_count += 1
        @project.save!
        redirect_to admin_url(@project.group)
      else
        session[:attempted_url] = request.request_uri
        redirect_to authenticate_url(@project.group.id)
      end
    else
      redirect_to admin_url(@project.group)
    end
  end

  def new
    @project = Project.new
    @project.group_id = params[:group_id]
    @groups = Group.all
    render :layout => 'simple'
  end
  
  def edit
    @project = Project.find(params[:id])
  end
  
  def show
    @project = Project.find(params[:id])
  end
  
  private
  
  def generate_password(size = 3)
    c = %w(b c d f g h j k l m n p qu r s t v w x z ch cr fr nd ng nk nt ph pr rd sh sl sp st th tr lt)
    v = %w(a e i o u y)
    f, r = true, ''
    (size * 2).times do
      r << (f ? c[rand * c.size] : v[rand * v.size])
      f = !f
    end
    r
  end
end
