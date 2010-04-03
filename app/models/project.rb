class Project < ActiveRecord::Base
  has_many :events, :as => :event_producer
  belongs_to :group
  
  named_scope :approved, :conditions => {:approved => true}
  named_scope :alphabetical, :order => :name

  # Utility method for experimenting on the Rails console
  def fetch
    feed_objects = [self.blog_parser,self.source_code_parser].compact
    feed_cache = Feedzirra::Feed.update(feed_objects, {:timeout => 45})
    feed_cache = [feed_cache] unless feed_cache.is_a? Array
    self.update_from_feed!(feed_cache)
  end

  def blog_parser
    return nil if blog_feed.nil?

    feed_to_update               = Feedzirra::Parser::Atom.new
    feed_to_update.feed_url      = blog_feed
    feed_to_update.etag          = blog_etag
    feed_to_update.last_modified = blog_last_modified

    last_entry     = Feedzirra::Parser::AtomEntry.new
    last_entry.url = self.events.blog.last.permalink rescue nil
    feed_to_update.entries = [last_entry]

    return feed_to_update
  end

  def source_code_parser
    return nil if source_code_feed.nil?

    feed_to_update               = Feedzirra::Parser::Atom.new
    feed_to_update.feed_url      = source_code_feed
    feed_to_update.etag          = code_etag
    feed_to_update.last_modified = code_last_modified

    last_entry     = Feedzirra::Parser::AtomEntry.new
    last_entry.url = self.events.code.last.permalink rescue nil
    feed_to_update.entries = [last_entry]

    return feed_to_update
  end

  def update_from_feed!(feed_cache)
    @blog_feed_data = feed_cache.find {|f| f.feed_url == blog_feed }
    @source_code_feed_data = feed_cache.find {|f| f.feed_url == source_code_feed }
    self.blog_last_modified = @blog_feed_data.last_modified rescue nil
    self.blog_etag = @blog_feed_data.etag rescue nil
    self.code_last_modified = @source_code_feed_data.last_modified rescue nil
    self.code_etag = @source_code_feed_data.etag rescue nil
    self.save!
    generate_events!
  end
  
  # BEGIN synthetic attributes
  def age
    s = entry_age(last_source_code_entry)
    b = entry_age(last_blog_entry)
    score = s * s + s * b + b * b + s
    return score
  end
  
  def formatted_contributors
    contributors.nil? ? "nobody" : contributors_list.to_sentence
  end

  def number_of_contributors
    contributors.count(',')+1
  end
    
  def contributors_list
    contributors.split(/, ?/)
  end
  
  def blogs_this_week
    events.blog.count(:all, :conditions => ['updated_at > ?', Time.now-7.days])
  end
  
  def commits_this_week
    events.code.count(:all, :conditions => ['updated_at > ?', Time.now-7.days])
  end
  
  def activity_this_week
    events.count(:all, :conditions => ['updated_at > ?', Time.now-7.days])
  end
  
  def total_activity
    events.count
  end
  
  def blog_age
    entry_age(last_blog_entry)
  end

  def source_code_age
    entry_age(last_source_code_entry)
  end

  def last_update(column)
    case column
    when 'blog'
      return events.blog.last.created_at.strftime('%A, %B %d') rescue ''
    when 'source_code'
      return events.code.last.created_at.strftime('%A, %B %d') rescue ''
    end
  end

  def last_blog_entry
    events.blog.last
  end

  def last_source_code_entry
    events.code.last
  end
  
  # END synthetic attributes

  # BEGIN attribute customizations
  
  # Safari generates feed:// links, which sucks
  def source_code_feed=(feed)
    super(feed.gsub(/^feed:/, 'http:'))
  end
  
  def blog_feed=(feed)
    super(feed.gsub(/^feed:/, 'http:'))
  end
  
  # don't allow nulling out of fields to prevent overwrite
  # of hosting type-derrived fields during construction
  def source_code=(val)
    super(val) unless val.nil? || val == ''
  end
  
  def website=(val)
    super(val) unless val.nil? || val == ''
  end
  
  def wiki=(val)
    super(val) unless val.nil? || val == ''
  end
  
  # once set, you can't get back project hosting type
  def github; ""; end
  def googlecode; ""; end
  def redmine; ""; end
  
  # Support for various hosting types
  def github=(project_name)
    return if project_name.nil? or project_name.empty?
    components = project_name.split('/')
    self.source_code = "http://github.com/#{project_name}/"
    self.source_code_feed = "http://github.com/feeds/#{components[0]}/commits/#{components[1]}/master"
    self.wiki = "http://wiki.github.com/#{project_name}/"
  end
  
  def googlecode=(name)
    return if name.nil? or name.empty?
    self.website = "http://code.google.com/p/#{name}/"
    self.source_code = "http://code.google.com/p/#{name}/source/browse/"
    self.source_code_feed = "http://code.google.com/feeds/p/#{name}/svnchanges/basic"
    self.wiki = "http://code.google.com/p/#{name}/w/list"
  end
  
  def redmine=(home)
    return if home.nil? or home.empty?
    name = home.split('/').last
    base = home.match("(https?://[^/]*)/.*")[1]
    self.website = home
    self.blog = "#{base}/projects/#{name}/news"
    self.blog_feed = "#{base}/projects/#{name}/news?format=atom"
    self.source_code = "#{base}/repositories/show/#{name}"
    self.source_code_feed = "#{base}/repositories/revisions/#{name}?format=atom"
    self.wiki = "#{base}/wiki/#{name}"
  end
  
  # END attribute customizations

  def before_save
    # go find feeds
    self.source_code_feed ||= FeedDetector.fetch_feed_url(self.source_code) rescue nil
    self.blog_feed ||= FeedDetector.fetch_feed_url(self.blog) rescue nil
  end
  
  private

  def entry_age(entry)
    published = entry.created_at rescue nil
    return 100 unless published

    age = Time.now - published
    days_old = (age / (60 * 60 * 24))
    return days_old
  end

  def generate_events!
    if @blog_feed_data
      @blog_feed_data.entries.each do |entry|
        Event.create_if_new(self, entry, 'blog')
      end
    end

    if @source_code_feed_data
      @source_code_feed_data.entries.each do |entry|
        Event.create_if_new(self, entry, 'code')
      end
    end
  end
end
