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
    content_for(:javascript) { raw create_template(a, b, &block) }
  end
  

  def create_template(header, footer, &block)
    # Get the data from the block 
    data = capture(&block)
    header + "\n" + data + "\n" + footer
  end
  
  def tools_links(tools)
    tools.collect { |tool| link_to tool.name, tool_path(tool) }.join(", ")
  end
  
  def sorting_name(name)
    case name.split("_").first
      when 'sites' then 'Sites Using'
      when 'category' then 'Category'
      when 'toolname' then 'Tool Name'
      when 'sitename' then 'Site Name'
      when 'alexa' then 'Alexa Rank'
      when 'google' then 'Google PageRank'
      when 'tools' then 'Tools Count'
    end
  end
end