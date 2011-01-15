class AddSitesCountToTools < ActiveRecord::Migration
  def self.up
    add_column :tools, :sites_count, :int, :default => 0
  end

  def self.down
    remove_column :tools, :sites_count
  end
end
