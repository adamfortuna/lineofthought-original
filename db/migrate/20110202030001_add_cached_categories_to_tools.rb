class AddCachedCategoriesToTools < ActiveRecord::Migration
  def self.up
    add_column :tools, :cached_categories, :text
  end

  def self.down
    remove_column :tools, :cached_categories
  end
end
