module SiteHelper
  def site_tools(site, count=2)
    return nil unless site.top_tools
    site.top_tools[:tools].sample(2).collect { |tool| content_tag(:li, link_to(tool[:name], "/tools/#{tool[:param]}")) }.join
  end
  
  def tool_sites(tool, count=2)
    return nil unless tool.top_sites
    tool.top_sites[:sites].sample(2).collect { |site| content_tag(:li, link_to(site[:name], "/sites/#{site[:param]}")) }.join
  end
  
  def tool_sites_count(tool)
    "<li class=\"sites\"><a href=\"#{tool_path(tool)}\"><em>#{tool.sites_count}</em>sites</a></li>"
  end

  def tool_articles_count(tool)
    "<li class=\"links\"><a href=\"#{tool_path(tool)}\"><em>0</em>articles</a></li>"
  end
  
  def tool_categories(tool)
    language = tool.language_id? ? "<li><a href='#{tool.cached_language[:param]}'>#{tool.cached_language[:name]}</a></li>" : ""
    language + tool.cached_categories.collect do |category|
      "<li><a href='/categories/#{category[:param]}'>#{category[:name]}</a></li>"
    end.join
  end
  
  def article_sites(article, count=2)
    return nil unless article.cached_sites
    article.cached_sites.sort_by{rand}[0..count-1].collect { |site| content_tag(:li, link_to(site[:name], "/sites/#{site[:param]}")) }.join
  end
  
  def article_tools(article, count=2)
    return nil unless article.cached_tools
    article.cached_tools.sort_by{rand}[0..count-1].collect { |tool| content_tag(:li, link_to(tool[:name], "/tools/#{tool[:param]}")) }.join
  end
end