class AddSortingIndex < ActiveRecord::Migration
  def self.up
    add_index :tools, :name
    add_index :categories, :name
    add_index :sites, :title
  end

  def self.down
    remove_index :tools, :name
    remove_index :categories, :name
    remove_index :sites, :title
  end
end
