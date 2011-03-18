class CreateBookmarkConnections < ActiveRecord::Migration
  def self.up
    create_table :bookmark_connections do |t|
      t.datetime :created_at
      t.integer :bookmark_id, :using_id
    end
    add_index :bookmark_connections, :bookmark_id
    add_index :bookmark_connections, :using_id

    add_column :usings, :cached_bookmarks, :text
    add_column :usings, :bookmarks_count, :int, :default => 0
  end

  def self.down
    drop_table :bookmark_connections
    remove_column :usings, :cached_bookmarks
    remove_column :usings, :bookmarks_count
  end
end
