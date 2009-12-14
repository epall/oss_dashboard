atom_feed do |feed|
  feed.title("RCOS Blog aggregate")
  feed.updated(@events.first.updated_at)
 
  for event in @events
    feed.entry(event, :url => event.permalink) do |entry|
      entry.title(event.title)
      entry.content(event.summary, :type => 'html')
    end
  end
end
