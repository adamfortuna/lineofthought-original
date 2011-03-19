class AddVideoToBookmarks < ActiveRecord::Migration
  def self.up
    add_column :bookmarks, :is_video, :boolean, :default => false
    add_column :bookmarks, :is_presentation, :boolean, :default => false
  end

  def self.down
    remove_column :bookmarks, :is_video
    remove_column :bookmarks, :is_presentation
  end
end
