class AddUidToBookmarks < ActiveRecord::Migration
  def self.up
    add_column :bookmarks, :uid, :string
    Bookmark.all.each do |bookmark|
      bookmark.update_attribute(:uid, bookmark.uri.uid)
    end
  end

  def self.down
    remove_column :bookmarks, :uid
  end
end
