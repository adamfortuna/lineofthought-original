class AddTopAssociationsToToolsAndSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :top_tools, :text
    add_column :tools, :top_sites, :text
  end

  def self.down
    remove_column :sites, :top_tools
    remove_column :tools, :top_sites
  end
end
