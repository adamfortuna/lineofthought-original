module SiteHelper
  def site_tools(site, count=2)
    site.tools.limit(2).order("sites_count desc").collect { |tool| content_tag(:li, link_to(tool.name, tool)) }.join
  end
  
  def tool_sites(tool, count=2)
    tool.sites.all(:limit => count, :order => :alexa_global_rank).collect { |site| content_tag(:li, link_to(site.title, site)) }.join
  end
  
  def tool_categories(tool)
    tool.categories.sort {|a,b| a.name <=> b.name }.collect { |category| content_tag(:li, link_to(category.name, category)) }.join
  end
end