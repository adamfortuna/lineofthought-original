class UsingSweeper < ActionController::Caching::Sweeper
  observe Using
  
  def after_update(widget)
    expire_cache_for(widget)
  end

  def after_destroy(widget)
    expire_cache_for(widget)
  end

  def after_create(widget)
    expire_cache_for(widget)
  end

  private
  def expire_cache_for(using)
    return unless using && using.tool && using.site
    expire_action(:controller => "tools", :action => "show", :id => using.tool.cached_slug)
    expire_fragment('featured_tools') if using.tool.featured?
    
    expire_action(:controller => "sites", :action => "show", :id => using.site.cached_slug)    
    expire_fragment('featured_sites') if using.site.featured?
  end
end