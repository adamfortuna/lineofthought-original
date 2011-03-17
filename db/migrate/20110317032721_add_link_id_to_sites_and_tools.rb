class AddLinkIdToSitesAndTools < ActiveRecord::Migration
  def self.up
    add_column :sites, :link_id, :int
    add_column :tools, :link_id, :int
  end

  def self.down
    remove_column :sites, :link_id
    remove_column :tools, :link_id
  end
end
