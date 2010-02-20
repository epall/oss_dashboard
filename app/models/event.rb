class Event < ActiveRecord::Base
  belongs_to :project
  belongs_to :personal_blog
  
  validates_uniqueness_of :identifier
  default_scope :order => 'created_at ASC'
  named_scope :blog, :conditions => {:entry_type => 'blog'}
  named_scope :code, :conditions => {:entry_type => 'code'}
  
  def self.create_if_new(parent, raw_article, type)
    return if raw_article.title.nil?
    event = Event.new do |e|
      e.project = parent if parent.is_a? Project
      e.personal_blog = parent if parent.is_a?(PersonalBlog)
      
      e.entry_type = type
      e.title = raw_article.title
      e.summary = raw_article.summary
      e.content = raw_article.content || e.summary
      e.created_at = raw_article.published
      e.updated_at = raw_article.updated
      e.permalink = raw_article.url
      e.identifier = raw_article.id
    end
    return event.save
  end
  
  def parent
    self.project || self.personal_blog
  end
end
