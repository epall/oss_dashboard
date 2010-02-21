class ProjectController < ApplicationController
  layout 'application', :except => [:new, :create]

  def create
    @project = Project.new
    @project.name = params[:name]
    @project.contributors = params[:contributors]
    @project.group = Group.last # TODO generalize
    @project.description = params[:description]
    
    if not params[:github].empty?
      @project.blog = params[:blog_url]
      @project.blog_feed = FeedDetector.fetch_feed_url(@project.blog) rescue ""
      components = params[:github].split('/')
      @project.source_code = "http://github.com/#{params[:github]}/"
      @project.source_code_feed = "http://github.com/feeds/#{components[0]}/commits/#{components[1]}/master"
      @project.wiki = "http://wiki.github.com/#{params[:github]}/"
    elsif not params[:redmine_home].empty?
      home = params[:redmine_home]
      name = home.split('/').last
      base = home.match("(https?://[^/]*)/.*")[1]
      @project.website = home
      @project.blog = "#{base}/projects/#{name}/news"
      @project.blog_feed = "#{base}/projects/#{name}/news?format=atom"
      @project.source_code = "#{base}/repositories/show/#{name}"
      @project.source_code_feed = "#{base}/repositories/show/#{name}?format=atom"
      @project.wiki = "#{base}/wiki/#{name}"
    elsif not params[:googlecode].empty?
      name = params[:googlecode]
      @project.blog = params[:blog_url]
      @project.blog_feed = FeedDetector.fetch_feed_url(@project.blog) rescue ""
      @project.source_code = 
      @project.website = "http://code.google.com/p/#{name}/"
      @project.source_code = "http://code.google.com/p/#{name}/source/browse/"
      @project.source_code_feed = "http://code.google.com/feeds/p/#{name}/svnchanges/basic"
      @project.wiki = "http://code.google.com/p/#{name}/w/list"
    else # custom
      @project.blog = params[:blog_url]
      @project.blog_feed = FeedDetector.fetch_feed_url(@project.blog) rescue ""
      @project.source_code = params[:custom_url]
      @project.source_code_feed = FeedDetector.fetch_feed_url(@project.source_code) rescue ""
      @project.wiki = params[:custom_wiki]
    end
    
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
    # @project.save!

    redirect_to :controller => 'group', :action => 'show', :id => @project.group
  end

  def approve
    @project = Project.find(params[:id], :include => [:group])
    if request.method == :post
      if params[:admin_password] == @project.group.admin_password
        @project.update_attribute('approved', true)
        redirect_to :controller => :project, :action => :fetch
      else
      flash[:notice] = "Access denied"
      redirect_to :back
      end
    end
  end

  def new
    render :layout => 'simple'
  end
  
  def edit
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
