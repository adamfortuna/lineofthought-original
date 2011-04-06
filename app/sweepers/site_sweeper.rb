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
    return unless site && site.cached_slug
    expire_action(:controller => "sites", :action => "show", :id => site.cached_slug)
    expire_fragment('featured_sites') if site.featured?
  end
end