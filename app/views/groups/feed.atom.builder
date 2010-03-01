atom_feed(:root_url => url_for(:format => :html)) do |feed|
  feed.title(@group.name+" blog aggregate")
  feed.updated(@events.first.updated_at)
 
  for event in @events
    feed.entry(event, :url => event.permalink) do |entry|
      entry.title(event.title)
      entry.content(event.content, :type => 'html')
      entry.author event.event_producer.name
    end
  end
end
