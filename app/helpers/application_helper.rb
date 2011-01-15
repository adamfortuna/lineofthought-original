module ApplicationHelper
  
  # Used in views to set the page title for the layout
  def title(page_title)
    @title = page_title
    content_for(:title) { page_title }
  end

  def javascript(&block)
    a = '<script type="text/javascript">' + \
        '// <![CDATA['
    b = '// ]]>' + \
        '</script>'
    content_for(:javascript) { create_template(a, b, &block) }
  end
  

  def create_template(header, footer, &block)
    # Get the data from the block 
    data = capture(&block)
    res = header + data + footer

    # Use concat method to pass text back to the view 
    concat(res)
  end
  
  def tools_links(tools)
    tools.collect { |tool| link_to tool.name, tool_path(tool) }.join(", ")
  end
  
  def sorting_name(name)
    case name
      when 'sites_desc' then 'Sites Using'
      when 'category_asc' then 'Category'
      when 'toolname_asc' then 'Tool Name'
      when 'sitename_asc' then 'Site Name'
      when 'alexa_asc' then 'Alexa Rank'
      when 'google_desc' then 'Google PageRank'
      when 'tools_desc' then 'Tools Count'
    end
  end
end