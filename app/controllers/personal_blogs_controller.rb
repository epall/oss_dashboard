class PersonalBlogsController < ApplicationController
  # GET /personal_blogs
  # GET /personal_blogs.xml
  def index
    @personal_blogs = PersonalBlog.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @personal_blogs }
    end
  end

  # GET /personal_blogs/1
  # GET /personal_blogs/1.xml
  def show
    @personal_blog = PersonalBlog.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @personal_blog }
    end
  end

  # GET /personal_blogs/new
  # GET /personal_blogs/new.xml
  def new
    @personal_blog = PersonalBlog.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @personal_blog }
    end
  end

  # GET /personal_blogs/1/edit
  def edit
    @personal_blog = PersonalBlog.find(params[:id])
  end

  # POST /personal_blogs
  # POST /personal_blogs.xml
  def create
    @personal_blog = PersonalBlog.new(params[:personal_blog])
    @personal_blog.feed = @personal_blog.feed.gsub(/^feed/, 'http')
    @personal_blog.group = Group.first

    respond_to do |format|
      if @personal_blog.save
        format.html { redirect_to(@personal_blog) }
        format.xml  { render :xml => @personal_blog, :status => :created, :location => @personal_blog }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @personal_blog.errors, :status => :unprocessable_entity }
      end
    end
  end

  # # PUT /personal_blogs/1
  # # PUT /personal_blogs/1.xml
  # def update
  #   @personal_blog = PersonalBlog.find(params[:id])
  # 
  #   respond_to do |format|
  #     if @personal_blog.update_attributes(params[:personal_blog])
  #       flash[:notice] = 'PersonalBlog was successfully updated.'
  #       format.html { redirect_to(@personal_blog) }
  #       format.xml  { head :ok }
  #     else
  #       format.html { render :action => "edit" }
  #       format.xml  { render :xml => @personal_blog.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /personal_blogs/1
  # DELETE /personal_blogs/1.xml
  def destroy
    @personal_blog = PersonalBlog.find(params[:id])
    @personal_blog.destroy

    respond_to do |format|
      format.html { redirect_to(personal_blogs_url) }
      format.xml  { head :ok }
    end
  end
  
  def approve
    @blog = PersonalBlog.find(params[:id], :include => [:group])
    if request.method == :post
      if params[:admin_password] == @blog.group.admin_password
        @blog.update_attribute('approved', true)
        redirect_to :controller => :groups, :action => :fetch, :id => @blog.group.id
      else
      flash[:notice] = "Access denied"
      redirect_to :back
      end
    end
  end
end
