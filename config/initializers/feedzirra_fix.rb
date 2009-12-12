module Feedzirra
  module FeedUtilities
    def update_from_feed(feed)
      self.new_entries += find_new_entries_for(feed)
      self.entries.unshift(*self.new_entries)

      @updated = false
      UPDATABLE_ATTRIBUTES.each do |name|
        updated = update_attribute(feed, name)
        @updated ||= updated
      end
    end
  end
end
