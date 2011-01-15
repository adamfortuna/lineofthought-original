class AddExceptToSitesAndTools < ActiveRecord::Migration
  def self.up
    add_column :sites, :excerpt, :string, :limit => 140
    add_column :tools, :excerpt, :string, :limit => 140
    add_column :categories, :excerpt, :string, :limit => 140
  end

  def self.down
    remove_column :sites, :excerpt
    remove_column :tools, :excerpt
    remove_column :categories, :excerpt
  end
end
