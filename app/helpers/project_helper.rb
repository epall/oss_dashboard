require 'Color'

module ProjectHelper
  def column_contents(column, project)
    value = project[column]
    return 'No' if value.nil?
    if column == 'blog'
      text = project.last_blog_entry.title rescue 'No updates'
      text = truncate(text, :length => 50)
      "<div class=\"title\"><a href=\"#{value}\">#{text}</a></div><div class=\"time\">#{project.last_update(column)}</div>"
    elsif column == 'contributors'
      value.gsub(',', "\n<br>\n")
    elsif column == 'source_code'
      render_source_code(project)
    elsif column == 'name'
      name = ''
      if project.website.nil?
        name = value
      else
        name = "<a href=\"#{project.website}\">#{value}</a>"
      end
      name
    elsif value.is_a? String and value.match(/http/) # wiki
      "<a href=\"#{value}\">Yes</a>"
    else
      value
    end
  end

  def render_source_code(project)
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

  def value_style(col_name, project)
    if col_name == 'blog' && project['blog']
      return "background-color: " + color_from_age(project.blog_age)
    elsif col_name == 'source_code' && project.source_code_feed
      return "background-color: " + color_from_age(project.source_code_age)
    else
      return ''
    end
  end

  def value_class(col_name, project)
    value = project[col_name]
    ret = col_name + ' '
    ret += 'red' if value.nil?

    if col_name == 'source_code'
      if !project.source_code_feed
        ret += 'green'
      end
    elsif col_name == 'wiki'
      ret += 'green' if !value.nil?
    end
    return ret
  end

  def color_from_age(days_old)
    return Color::HSL.new(100 - days_old, 53, 70).html()
  end
  
  def has_have(num)
    return "<strong>" + num.to_s() + "</strong>" + (num.to_i == 1 ? " has " : " have ")
  end
end
