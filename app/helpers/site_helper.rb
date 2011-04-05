module SiteHelper
  def site_tools(site, count=2, format=nil)
    return nil unless site.cached_tools
    site.cached_tools.sample(count).collect { |tool| "<li><a href='/tools/#{tool[:param]}#{".#{format}" if format} '>#{tool[:name]}</a></li>" }.join
  end
  
  def comma_site_tools(site, count=3, format=nil)
    return nil unless site.cached_tools
    tools = site.cached_tools.sample(count).collect { |tool| tool[:name] }.uniq
    return tools.first if tools.length == 1
    tools[0..(tools.length-2)].join(", ") + " and " + tools.last
  end
  
  def site_share_message(site, count=3)
    "#{site.title} is using at least #{pluralize(site.tools_count, "tool")} including #{comma_site_tools(site, count) || "HTML"} (via Line Of Thought)"
  end



  def tool_sites(tool, count=3, format=nil)
    return nil unless tool.cached_sites
    tool.cached_sites.sample(count).collect { |site| "<li><a href='/sites/#{site[:param]}#{".#{format}" if format}'>#{site[:name]}</a></li>" }.join
  end

  def comma_tool_sites(tool, count=3, format=nil)
    return nil unless tool.cached_sites
    sites = tool.cached_sites.sample(count).collect { |site| site[:name] }.uniq
    return sites.first if sites.length == 1
    sites[0..(sites.length-2)].join(", ") + " and " + sites.last
  end
  
  def tool_share_message(tool, count=3)
    "#{tool.name} is using on at least #{pluralize(tool.sites_count, "sites")} including #{comma_tool_sites(tool, count)} (via Line Of Thought)"
  end
  
  
    
  def tool_categories(tool, format=nil)
    language = (tool.language_id? && tool.cached_language) ? "<li><a href='/tools/#{tool.cached_language[:param]}#{".#{format}" if format}'>#{tool.cached_language[:name]}</a></li>" : ""
    language + (tool.cached_categories || []).collect do |category|
      "<li><a href='/tools#{".#{format}" if format}?category=#{category[:param]}'>#{category[:name]}</a></li>"
    end.join
  end
  
  def bookmark_sites(bookmark, count=2, format=nil)
    return nil unless bookmark.cached_sites
    bookmark.cached_sites.sample(count).collect { |site| "<li><a href='/sites/#{site[:param]}#{".#{format}" if format}'>#{site[:name]}</a>" }.join
  end
  
  def bookmark_tools(bookmark, count=2, format=nil)
    return nil unless bookmark.cached_tools
    bookmark.cached_tools.sample(count).collect { |tool| "<li><a href='/tools/#{tool[:param]}#{".#{format}" if format}'>#{tool[:name]}</a></li>" }.join
  end
  
  def using_bookmarks(using, count=2, format=nil)
    return "" unless using.cached_bookmarks
    
    content_tag :ul, :class => "bookmarks"  do
      raw(
        using.cached_bookmarks.collect do |bookmark|
          content_tag :li do
            link_to bookmark[:title], "/bookmarks/#{bookmark[:param]}#{".#{format}" if format}"
          end
        end.join
      )
    end
  end
  
  def bookmark_references(bookmark)
    if bookmark.sites_count == 0 && bookmark.tools_count == 0
      return "We don't know of any tools or sites refenced in this bookmark."
    end
    sites = bookmark.sites_count > 0 ? pluralize(bookmark.sites_count, "site") : nil
    tools = bookmark.tools_count > 0 ? pluralize(bookmark.tools_count, "tool") : nil
    return "We know of #{[sites, tools].compact.join(" and ")} referenced in this bookmark."
  end
end