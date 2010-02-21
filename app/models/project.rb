class Project < ActiveRecord::Base
  has_many :events
  belongs_to :group
  
  named_scope :approved, :conditions => {:approved => true}

  def self.display_columns
    ["name", "contributors", "blog", "source_code", "wiki"]
  end
  
  def fetch
    feed_objects = [self.blog_parser,self.source_code_parser].compact
    feed_cache = Feedzirra::Feed.update(feed_objects, {:timeout => 45})
    feed_cache = [feed_cache] unless feed_cache.is_a? Array
    self.update_from_feed(feed_cache)
  end

  def age
    s = entry_age(last_source_code_entry)
    b = entry_age(last_blog_entry)
    score = s * s + s * b + b * b + s
    return score
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
  
  def number_of_contributors
    contributors.count(',')+1
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

  def update_from_feed(feed_cache)
    @blog_feed_data = feed_cache.find {|f| f.feed_url == blog_feed }
    @source_code_feed_data = feed_cache.find {|f| f.feed_url == source_code_feed }
    self.blog_last_modified = @blog_feed_data.last_modified rescue nil
    self.blog_etag = @blog_feed_data.etag rescue nil
    self.code_last_modified = @source_code_feed_data.last_modified rescue nil
    self.code_etag = @source_code_feed_data.etag rescue nil
    self.save!
    generate_events()
  end
  
  def generate_events
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


  def before_save
    self.website = nil if self.website == ''
    self.wiki = nil if self.wiki == ''
  end
  
  private

  def entry_age(entry)
    published = entry.created_at rescue nil
    return 100 unless published

    age = Time.now - published
    days_old = (age / (60 * 60 * 24))
    return days_old
  end
end
