class AddArticleCachesToToolsAndSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :articles_count, :integer, :default => true
    add_column :sites, :cached_articles, :text
    add_column :tools, :articles_count, :integer, :default => true
    add_column :tools, :cached_articles, :text    
  end

  def self.down
    remove_column :sites, :articles_count
    remove_column :sites, :cached_articles
    remove_column :tools, :articles_count
    remove_column :tools, :cached_articles
  end
end
