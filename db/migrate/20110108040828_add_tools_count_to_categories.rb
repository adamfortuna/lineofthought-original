class AddToolsCountToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :tools_count, :int, :default => 0
  end

  def self.down
    remove_column :categories, :tools_count
  end
end
