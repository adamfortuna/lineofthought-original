class RenameAnnotations < ActiveRecord::Migration
  def self.up
    rename_table :annotations, :bookmark_annotations
    rename_table :user_bookmarks, :bookmark_users
    add_column :users, :bookmarks_count, :integer, :default => 0
  end

  def self.down
    rename_table :bookmark_annotations, :annotations
    rename_table :bookmark_users, :user_bookmarks
    remove_column :users, :bookmarks_count
  end
end
