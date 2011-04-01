class RemoveUserBookmarkIdFromBookmarkAnnotations < ActiveRecord::Migration
  def self.up
    remove_column :bookmark_annotations, :user_bookmark_id
  end

  def self.down
    add_column :bookmark_annotations, :user_bookmark_id, :int
  end
end
