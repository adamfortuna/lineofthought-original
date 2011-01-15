class AddToolsCountToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :tools_count, :integer, :default => 0
  end

  def self.down
    remove_column :sites, :tools_count
  end
end
