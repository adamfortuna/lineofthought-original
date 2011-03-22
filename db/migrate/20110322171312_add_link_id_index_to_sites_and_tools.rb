class AddLinkIdIndexToSitesAndTools < ActiveRecord::Migration
  def self.up
    add_index :tools, :link_id
    add_index :sites, :link_id
  end

  def self.down
    remove_index :tools, :link_id
    remove_index :sites, :link_id
  end
end
