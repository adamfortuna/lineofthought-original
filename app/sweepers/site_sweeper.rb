class SiteSweeper < ActionController::Caching::Sweeper
  observe Site
  
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
  def expire_cache_for(widget)
    expire_action(:controller => "sites", :action => "show", :id => widget.cached_slug)
    expire_action(:controller => "sites", :action => "show", :id => widget.cached_slug, :logged_in => true)
    expire_action(:controller => "sites", :action => "show", :id => widget.cached_slug, :logged_in => true, :claimed => true)
  end
end