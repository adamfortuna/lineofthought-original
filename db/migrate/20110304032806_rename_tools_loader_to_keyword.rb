class RenameToolsLoaderToKeyword < ActiveRecord::Migration
  def self.up
    rename_column :tools, :loader_regex, :keyword
  end

  def self.down
    rename_column :tools, :keyword, :loader_regex
  end
end
