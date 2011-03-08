class AddLoaderRegexToTools < ActiveRecord::Migration
  def self.up
    add_column :tools, :loader_regex, :string
  end

  def self.down
    remove_column :tools, :loader_regex
  end
end
