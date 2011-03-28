class SiteSweeper < ActionController::Caching::Sweeper
  observe Site
  
  def after_update(site)
    expire_cache_for(site)
  end

  def after_destroy(site)
    expire_cache_for(site)
  end

  def after_create(site)
    expire_cache_for(site)
  end

  private
  def expire_cache_for(site)
    expire_action(:controller => "sites", :action => "show", :id => site.cached_slug)
    expire_action(:controller => "sites", :action => "show", :id => site.cached_slug, :logged_in => true)
    expire_action(:controller => "sites", :action => "show", :id => site.cached_slug, :logged_in => true, :claimed => true)
    
    expire_fragment('featured_sites') if site.featured?
  end
end