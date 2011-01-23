module SiteHelper
  def site_tools(site, count=2)
    links = site.tools.all(:limit => count, :order => :sites_count).collect { |tool| link_to tool.name, tool_path(tool) }.join(", ")
    links += " and #{pluralize(site.tools_count-count, 'other tools')}" if site.tools_count > count
    return links + "."
  end
  
  def tool_sites(tool, count=2)
    tool.sites.all(:limit => count, :order => :alexa_global_rank).collect { |site| content_tag(:li, link_to(site.title, site)) }.join
  end
  
  def tool_categories(tool)
    tool.categories.sort {|a,b| a.name <=> b.name }.collect { |category| content_tag(:li, link_to(category.name, category)) }.join
  end
end