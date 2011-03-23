module ApplicationHelper
  
  # Used in views to set the page title for the layout
  def title(page_title)
    @title = page_title
    content_for(:title) { page_title }
  end
  
  def description(page_description)
    @description = page_description
    content_for(:description) { page_description }
  end
  
  def page_description
    @description || "Line Of Thought tracks what powers the web. Find out what tools power the sites you visit, or add your own site or tools."
  end
  
  def body_class(classes)
    @classes = classes
    content_for(:body_classes) { classes }
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
      when 'jobs' then 'Jobs Count'
      when 'bookmarks' then 'Bookmarks Count'
    end
  end

  def sorting_class(name)
    case name.split("_").first
      when 'sites' then 'sort-sites'
      when 'category' then 'sort-category'
      when 'toolname' then 'sort-tool'
      when 'sitename' then 'sort-site'
      when 'alexa' then 'sort-alexa'
      when 'google' then 'sort-pagerank'
      when 'tools' then 'sort-tools-count'
      when 'jobs' then 'sort-jobs-count'
      when 'bookmarks' then 'sort-bookmarks-count'
    end
  end
end