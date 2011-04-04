class AddLockedToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :locked, :boolean, :default => false
    add_column :sites, :locked_by, :integer
  end

  def self.down
    remove_column :sites, :locked
    remove_column :sites, :locked_by
  end
end
