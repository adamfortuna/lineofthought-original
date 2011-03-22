module SiteHelper
  def site_tools(site, count=2)
    return nil unless site.cached_tools
    site.cached_tools.sample(count).collect { |tool| "<li><a href='/tools/#{tool[:param]}'>#{tool[:name]}</a></li>" }.join
  end
  
  def tool_sites(tool, count=3)
    return nil unless tool.cached_sites
    tool.cached_sites.sample(count).collect { |site| "<li><a href='/sites/#{site[:param]}'>#{site[:name]}</a></li>" }.join
  end
  
  def tool_categories(tool)
    language = (tool.language_id? && tool.cached_language) ? "<li><a href='#{tool.cached_language[:param]}'>#{tool.cached_language[:name]}</a></li>" : ""
    language + (tool.cached_categories || []).collect do |category|
      "<li><a href='/categories/#{category[:param]}'>#{category[:name]}</a></li>"
    end.join
  end
  
  def bookmark_sites(bookmark, count=2)
    return nil unless bookmark.cached_sites
    bookmark.cached_sites.sample(count).collect { |site| "<li><a href='/sites/#{site[:param]}'>#{site[:name]}</a>" }.join
  end
  
  def bookmark_tools(bookmark, count=2)
    return nil unless bookmark.cached_tools
    bookmark.cached_tools.sample(count).collect { |tool| "<li><a href='/tools/#{tool[:param]}'>#{tool[:name]}</a></li>" }.join
  end
  
  def using_bookmarks(using, count=2)
    return "" unless using.cached_bookmarks
    
    content_tag :ul, :class => "bookmarks"  do
      raw(
        using.cached_bookmarks.collect do |bookmark|
          content_tag :li do
            link_to bookmark[:title], "/bookmarks/#{bookmark[:param]}"
          end
        end.join
      )
    end
  end
end