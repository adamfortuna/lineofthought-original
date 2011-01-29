class RemoveExceprts < ActiveRecord::Migration
  def self.up
    remove_column :tools, :excerpt
    remove_column :sites, :excerpt
  end

  def self.down
    add_column :tools, :excerpt, :string
    add_column :sites, :excerpt, :string
  end
end
