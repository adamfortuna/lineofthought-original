class AddFeaturedToSitesAndTools < ActiveRecord::Migration
  def self.up
    add_column :sites, :featured, :boolean, :default => false
    add_column :tools, :featured, :boolean, :default => false
    Site.update_all "featured = true", "cached_slug IN ('twitter', 'reddit', 'foursquare', 'disqus', 'facebook')"
    Tool.update_all "featured = true", "cached_slug IN ('ruby-on-rails', 'mongodb', 'jquery', 'redis', 'python')"
    add_index :sites, :featured
    add_index :tools, :featured
  end

  def self.down
    remove_column :sites, :featured
    remove_column :tools, :featured
  end
end
