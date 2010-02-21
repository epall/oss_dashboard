class PersonalBlog < ActiveRecord::Base
  belongs_to :group
  has_many :events
  named_scope :approved, :conditions => {:approved => true}
  
  validates_presence_of :name, :weblink, :feed
  
  def fetch
    feed_objects = [self.feed_parser]
    feed_cache = Feedzirra::Feed.update(feed_objects, {:timeout => 45})
    feed_cache = [feed_cache] unless feed_cache.is_a? Array
    expire_page :controller => 'events', :action => 'index'
    self.update_from_feed(feed_cache)
  end

  def feed_parser
    feed_to_update               = Feedzirra::Parser::Atom.new
    feed_to_update.feed_url      = feed
    feed_to_update.etag          = etag
    feed_to_update.last_modified = last_modified

    last_entry     = Feedzirra::Parser::AtomEntry.new
    last_entry.url = self.events.last.permalink rescue nil
    feed_to_update.entries = [last_entry]

    return feed_to_update
  end
  
  def update_from_feed(feed_cache)
    @feed_data = feed_cache.find {|f| f.feed_url == feed }
    return if @feed_data.nil?
    # save modification data to avoid abusing servers
    self.last_modified = @feed_data.last_modified rescue nil
    self.etag = @feed_data.etag rescue nil
    self.save!
    
    #now generate the events
    @feed_data.entries.each do |entry|
      Event.create_if_new(self, entry, 'blog')
    end
  end
end
