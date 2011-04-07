class ToolSweeper < ActionController::Caching::Sweeper
  observe Tool
  
  def after_update(tool)
    expire_cache_for(tool)
  end

  def after_destroy(tool)
    expire_cache_for(tool)
  end

  def after_create(tool)
    expire_cache_for(tool)
  end

  private
  def expire_cache_for(tool)
    return unless tool && tool.cached_slug
    expire_action(:controller => "tools", :action => "show", :id => tool.cached_slug)
    expire_fragment('featured_tools') if tool.featured?
  end
end