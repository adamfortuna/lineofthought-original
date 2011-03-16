class AddIdentifierDataToLinks < ActiveRecord::Migration
  def self.up
    rename_column :links, :original_url, :url
    remove_column :links, :normalized_url
    remove_column :links, :normalized_root_url
    add_column :links, :canonical, :string
    add_column :links, :original_url, :string
  end

  def self.down
    rename_column :links, :url, :original_url
    add_column :links, :normalized_url, :string
    add_column :links, :normalized_root_url, :string
    remove_column :links, :canonical
    remove_column :links, :original_url, :string
  end
end
