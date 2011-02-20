class AddCachedSlugToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :cached_slug, :string
    add_index :articles, :cached_slug
  end

  def self.down
    remove_column :articles, :cached_slug
    remove_index :articles, :cached_slug
  end
end
