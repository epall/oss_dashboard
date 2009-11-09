class Project < ActiveRecord::Base
  def self.fetch
    projects = all
    urls = projects.map(&:blog_feed) + projects.map(&:source_code_feed)
    urls.compact!
    feed_cache = Feedzirra::Feed.fetch_and_parse(urls, {:timeout => 25})
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

  def update_from_feed(feed_cache)
    @blog_feed_data = feed_cache[blog_feed]
    @source_code_feed_data = feed_cache[source_code_feed]
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
      return publish_time(last_blog_entry).strftime('%m/%d') rescue "No updates"
    when 'source_code'
      return publish_time(last_source_code_entry).strftime('%m/%d') rescue "No updates"
    end
  end

  def last_blog_entry
    @blog_feed_data.entries.first rescue nil
  end

  def last_source_code_entry
    @source_code_feed_data.entries.first rescue nil
  end


  def before_save
    self.website = nil if self.website == ''
    self.wiki = nil if self.wiki == ''
  end
  
  private

  # different blog engines use different RSS fields to specifiy when an entry
  # was published. This method evens that all out so you always get a DateTime
  # for when the most recent entry was updated.
  def publish_time(entry)
    return nil if entry.nil?
    (entry.updated || entry.published || entry.pubDate).in_time_zone
  end

  def entry_age(entry)
    published = nil
    published = publish_time(entry)
    return 100 unless published

    age = Time.now - published
    days_old = (age / (60 * 60 * 24))
    return days_old
  end
end
