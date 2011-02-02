module SiteHelper
  def site_tools(site, count=2)
    return nil unless site.top_tools
    site.top_tools[:tools].sort_by{rand}[0..count-1].collect { |tool| content_tag(:li, link_to(tool[:name], tool[:param])) }.join
  end
  
  def tool_sites(tool, count=2)
    return nil unless tool.top_sites
    
    tool.top_sites[:sites].sort_by{rand}[0..count-1].collect { |site| content_tag(:li, link_to(site[:title], site[:param])) }.join
  end
  
  def tool_categories(tool)
    tool.cached_categories.collect do |category|
      "<li><a href='/categories/#{category[:param]}'>#{category[:name]}</a></li>"
    end.join
  end
end