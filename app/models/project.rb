class Project < ActiveRecord::Base
  has_many :events
  belongs_to :group
  
  named_scope :approved, :conditions => {:approved => true}
  
  def self.fetch(*args)
    projects = approved(:limit => args[0])
    feed_objects = projects.map(&:blog_parser) + projects.map(&:source_code_parser)
    feed_objects.compact!
    feed_cache = Feedzirra::Feed.update(feed_objects, {:timeout => 45})
    feed_cache = [feed_cache] unless feed_cache.is_a? Array
    feed_cache.reject! {|e| e.is_a? Fixnum}
    projects.each {|p| p.update_from_feed(feed_cache)}
    return projects.sort_by(&:age)
  end

  def self.display_columns
    ["name", "contributors", "blog", "source_code", "wiki"]
  end

  def age
    score = 0
    score += 1000 unless source_code
    score += 1000 unless blog
    score += 1000 unless wiki
    score += [entry_age(last_blog_entry), entry_age(last_source_code_entry)].compact.min
    return score
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
      return events.blog.last.created_at.strftime('%m/%d') rescue "No updates"
    when 'source_code'
      return events.code.last.created_at.strftime('%m/%d') rescue "No updates"
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
