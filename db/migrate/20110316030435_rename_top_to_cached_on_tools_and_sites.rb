class RenameTopToCachedOnToolsAndSites < ActiveRecord::Migration
  def self.up
    rename_column :sites, :top_tools, :cached_tools
    rename_column :tools, :top_sites, :cached_sites
  end

  def self.down
    rename_column :sites, :cached_tools, :top_tools
    rename_column :tools, :cached_sites, :top_sites
  end
end
