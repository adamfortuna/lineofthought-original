class UpdateBookmarksForMultipleUsers < ActiveRecord::Migration
  def self.up
    add_column :bookmarks, :user_bookmarks_count, :integer, :default => 0
    
    create_table :user_bookmarks do |t|
      t.datetime :created_at
      t.integer :bookmark_id, :user_id
      t.string :title
      t.text :description
      t.boolean :has_video, :default => false
      t.boolean :has_presentation, :default => false
    end
    add_index :user_bookmarks, :bookmark_id
    add_index :user_bookmarks, :user_id
    
    add_column :annotations, :user_bookmark_id, :integer
  end

  def self.down
    drop_table :user_bookmarks
    remove_column :bookmarks, :user_bookmarks_count
    remove_column :annotations, :user_bookmark_id    
  end
end
