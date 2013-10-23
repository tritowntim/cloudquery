module ApplicationHelper

  def render_value(value, data_type=nil)
    if data_type && data_type.downcase == 'boolean'
      "<span class=\"column-boolean\">#{format_boolean(value)}</span>".html_safe
    else
      value
    end
  end

  def format_boolean(value)
    if value == nil
      nil
    elsif value == 't'
      "true"
    else
      "false"
    end
  end

end
