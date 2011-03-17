class RenameArticlesToBookmarks < ActiveRecord::Migration
  def self.up
    drop_table :articles
    create_table "bookmarks", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "title"
      t.text     "url"
      t.text     "description"
      t.text     "cached_tools"
      t.text     "cached_sites"
      t.text     "cached_connections"
      t.boolean  "has_favicon",        :default => false
    end
    
    rename_column :annotations, :article_id, :bookmark_id
    rename_column :sites, :articles_count, :bookmarks_count
    rename_column :sites, :cached_articles, :cached_bookmarks
    rename_column :tools, :articles_count, :bookmarks_count
    rename_column :tools, :cached_articles, :cached_bookmarks
  end

  def self.down
    
    rename_column :annotations, :bookmark_id, :article_id
    rename_column :sites, :bookmarks_count, :articles_count
    rename_column :sites, :cached_bookmarks, :cached_articles
    rename_column :tools, :bookmarks_count, :articles_count
    rename_column :tools, :cached_bookmarks, :cached_articles
    
    drop_table :bookmarks
    create_table "articles", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "title"
      t.text     "url"
      t.text     "description"
      t.text     "cached_tools"
      t.text     "cached_sites"
      t.text     "cached_connections"
      t.string   "cached_slug"
      t.boolean  "has_favicon",        :default => false
    end
  end
end
