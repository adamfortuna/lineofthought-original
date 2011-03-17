module SiteHelper
  def site_tools(site, count=2)
    return nil unless site.cached_tools
    site.cached_tools.sample(2).collect { |tool| "<li><a href='/tools/#{tool[:param]}'>#{tool[:name]}</a>" }.join
  end
  
  def tool_sites(tool, count=2)
    return nil unless tool.cached_sites
    tool.cached_sites.sample(2).collect { |site| "<li><a href='/sites/#{site[:param]}'>#{site[:name]}</a>" }.join
  end
  
  def tool_categories(tool)
    language = tool.language_id? ? "<li><a href='#{tool.cached_language[:param]}'>#{tool.cached_language[:name]}</a></li>" : ""
    language + (tool.cached_categories || []).collect do |category|
      "<li><a href='/categories/#{category[:param]}'>#{category[:name]}</a></li>"
    end.join
  end
  
  def bookmark_sites(bookmark, count=2)
    return nil unless bookmark.cached_sites
    bookmark.cached_sites.sort_by{rand}[0..count-1].collect { |site| content_tag(:li, link_to(site[:name], "/sites/#{site[:param]}")) }.join
  end
  
  def bookmark_tools(bookmark, count=2)
    return nil unless bookmark.cached_tools
    bookmark.cached_tools.sort_by{rand}[0..count-1].collect { |tool| content_tag(:li, link_to(tool[:name], "/tools/#{tool[:param]}")) }.join
  end
end