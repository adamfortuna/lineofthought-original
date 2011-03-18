class AddCachedSlugAndLinkIdToBookmarks < ActiveRecord::Migration
  def self.up
    add_column :bookmarks, :link_id, :int
    add_column :bookmarks, :cached_slug, :string
  end

  def self.down
    remove_column :bookmarks, :cached_slug
    remove_column :bookmarks, :link_id
  end
end
