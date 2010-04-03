class Group < ActiveRecord::Base
  has_many :projects
  has_many :personal_blogs
  
  has_many :personal_blog_events, :through => :personal_blogs, :source => :events
  has_many :project_events, :through => :projects, :source => :events
  
  def fetch
    projects = self.projects.approved
    feed_objects = projects.map(&:blog_parser) + projects.map(&:source_code_parser)
    feed_objects += self.personal_blogs.approved.map(&:feed_parser)
    feed_objects.compact!
    feed_cache = Feedzirra::Feed.update(feed_objects, {:timeout => 45})
    feed_cache = [feed_cache] unless feed_cache.is_a? Array
    feed_cache.reject! {|e| e.is_a? Fixnum}
    projects.each {|p| p.update_from_feed!(feed_cache)}
    personal_blogs.each {|b| b.update_from_feed!(feed_cache)}
  end
  
  def events
    # TODO this is really slow
    entries = personal_blog_events + project_events.blog
    return entries.sort_by(&:created_at).reverse
  end
  
  def as_json(options = {})
    {:name => name, :description => description, :projects =>
      projects.approved.map {|p| {:name => p.name,
                                  :description => p.description,
                                  :contributors => p.contributors_list,
                                  :blog_url => p.blog,
                                  :source_code_url => p.source_code}}}
  end
end
