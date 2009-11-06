module ProjectHelper
  def column_contents(column, project)
    value = project[column]
    return 'No' if value.nil?
    if column == 'blog'
      if value.is_a? String
        "<a href=\"#{value}\">Yes</a> (#{project.last_update(column)})"
      else
        "<a href=\"#{value['Web']}\">Yes</a> (#{project.last_update(column)})"
      end
    elsif column == 'contributors'
      value.gsub(',', "\n<br>\n")
    elsif column == 'source_code'
      render_source_code(project)
    elsif column == 'name'
      if project.website.nil?
        value
      else
        "<a href=\"#{project.website}\">#{value}</a>"
      end
    elsif value.is_a? String and value.match(/http/)
      "<a href=\"#{value}\">Yes</a>"
    else
      value
    end
  end

  def render_source_code(project)
    if project.source_code_feed
      "<a href=\"#{project.source_code}\">Yes</a> (#{project.last_update('source_code')})"
    else
      "<a href=\"#{project.source_code}\">Yes</a>"
    end
  end

  def value_style(col_name, project)
    if col_name == 'blog' && project['blog']
      return color_from_age(project.blog_age)
    elsif col_name == 'source_code' && project.source_code_feed
      return color_from_age(project.source_code_age)
    else
      return ''
    end
  end

  def value_class(col_name, project)
    value = project[col_name]
    unless ['name', 'contributors', 'website'].include? col_name
      return 'no' if value.nil?
      if col_name == 'blog'
        return ''
      elsif col_name == 'source_code'
        if project.source_code_feed
          return ''
        else
          return 'yes'
        end
      else
        return 'yes'
      end
    end
    ''
  end

  def color_from_age(days_old)
    green = red = 0
    if days_old < 15
      green = 255
      red = 255.0*(1.0 - 1.20**-days_old)
    elsif days_old < 30
      red = 255
      green = 255.0*(1.08**(15-days_old))
    else
      red = 255
      green = 80
    end
    return 'background-color:#'+sprintf('%02x', red.to_i)+sprintf('%02x', green)+'00;'
  end
end
