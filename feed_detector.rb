
require 'net/http'

class FeedDetector

  ##
  # return the feed url for a url
  # for example: http://blog.dominiek.com/ => http://blog.dominiek.com/feed/atom.xml
  # only_detect can force detection of :rss or :atom
  def self.fetch_feed_url(page_url, only_detect=nil)
    url = URI.parse(page_url)
    host_with_port = url.host
    host_with_port << ":#{url.port}" unless url.port == 80
    req = Net::HTTP::Get.new(url.path)
    # something fishy going on with URI.host
    res = Net::HTTP.start(url.host.gsub(/:[0-9]+/, ''), url.port) {|http|
      http.request(req)
    }
    feed_url = self.get_feed_path(res.body, only_detect)
    feed_url = "http://#{host_with_port}/#{feed_url.gsub(/^\//, '')}" unless !feed_url || feed_url =~ /^http:\/\// 
    feed_url || page_url
  end

  ##
  # get the feed href from an HTML document
  # for example:
  # ...
  # <link href="/feed/atom.xml" rel="alternate" type="application/atom+xml" />
  # ...
  # => /feed/atom.xml
  # only_detect can force detection of :rss or :atom
  def self.get_feed_path(html, only_detect=nil)
    unless only_detect && only_detect != :atom
      md ||= /<link.*href=['"]*([^\s'"]+)['"]*.*application\/atom\+xml.*>/.match(html) 
      md ||= /<link.*application\/atom\+xml.*href=['"]*([^\s'"]+)['"]*.*>/.match(html) 
    end
    unless only_detect && only_detect != :rss
      md ||= /<link.*href=['"]*([^\s'"]+)['"]*.*application\/rss\+xml.*>/.match(html) 
      md ||= /<link.*application\/rss\+xml.*href=['"]*([^\s'"]+)['"]*.*>/.match(html) 
    end
    md && md[1]
  end

end

