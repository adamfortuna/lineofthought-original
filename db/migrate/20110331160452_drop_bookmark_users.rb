class DropBookmarkUsers < ActiveRecord::Migration
  def self.up
    drop_table :bookmark_users
    add_column :bookmarks, :user_id, :int
    add_column :bookmarks, :type, :string, :default => "Bookmark"
    add_column :bookmarks, :parent_id, :int
    add_index :bookmarks, :user_id
  end

  def self.down
    create_table :bookmark_users do |t|
      t.datetime :created_at
      t.integer :bookmark_id, :user_id
      t.string :title
      t.text :description
      t.boolean :has_video, :default => false
      t.boolean :has_presentation, :default => false
    end
    add_index :bookmark_users, :bookmark_id
    add_index :bookmark_users, :user_id
  end
end
