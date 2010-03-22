module ProjectHelper
  def linked_name(project)
    if project.website.nil?
      project.name
    else
      "<a href=\"#{h project.website}\">#{h project.name}</a>"
    end
  end
  
  def linked_blog(project)
    text = project.last_blog_entry.title rescue 'No updates'
    text = truncate(text, :length => 50)
    "<div class=\"title\"><a href=\"#{project.blog}\">#{text}</a></div><div class=\"time\">#{project.last_update('blog')}</div>"
  end

  def linked_source_code(project)
    if project.source_code_feed
      text = project.last_source_code_entry.title rescue 'No updates'
      text ||= ''
      text.gsub!(/Changeset \[[a-f0-9]+\]: /, '')
      text.gsub!(/Revision .*: /, '')
      text = truncate(text, :length => 70)
      last_update = project.last_update('source_code')
      "<div class=\"title\"><a href=\"#{project.source_code}\">#{text}</a></div><div class=\"time\">#{last_update}</div>"
    else
      "<a href=\"#{project.source_code}\">Yes</a>"
    end
  end

  def color_from_age(days_old)
    return Color::HSL.new([120 - days_old*4.3, 0].max, 60, 70).html()
  end
  
  def has_have(num)
    return "<strong>" + num.to_s() + "</strong>" + (num.to_i == 1 ? " has " : " have ")
  end
end
