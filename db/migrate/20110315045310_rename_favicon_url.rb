class RenameFaviconUrl < ActiveRecord::Migration
  def self.up
    rename_column :favicons, :original_url, :url
  end

  def self.down
    rename_column :favicons, :url, :original_url
  end
end
