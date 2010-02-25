atom_feed(:root_url => url_for(:format => :html)) do |feed|
  feed.title("RCOS Blog aggregate")
  feed.updated(@events.first.updated_at)
 
  for event in @events
    feed.entry(event, :url => event.permalink) do |entry|
      entry.title(event.title)
      entry.content(event.content, :type => 'html')
      entry.author event.project.name
    end
  end
end
