class Event < ActiveRecord::Base
  belongs_to :project
  validates_uniqueness_of :identifier
  default_scope :order => 'created_at ASC'
  named_scope :blog, :conditions => {:entry_type => 'blog'}
  named_scope :code, :conditions => {:entry_type => 'code'}
  
  def self.create_if_new(project, raw_article, type)
    return if raw_article.title.nil?
    event = Event.new do |e|
      e.project = project
      e.entry_type = type
      e.title = raw_article.title
      e.summary = raw_article.summary
      e.content = raw_article.content
      e.created_at = raw_article.published
      e.updated_at = raw_article.updated
      e.permalink = raw_article.url
      e.identifier = raw_article.id
    end
    return event.save
  end
end
