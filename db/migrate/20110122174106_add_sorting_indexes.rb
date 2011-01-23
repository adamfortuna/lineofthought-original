class AddSortingIndexes < ActiveRecord::Migration
  def self.up
    add_index :tools, :sites_count
    add_index :sites, :google_pagerank
    add_index :sites, :alexa_global_rank
    add_index :sites, :tools_count
  end

  def self.down
    remove_index :tools, :sites_count
    remove_index :sites, :google_pagerank
    remove_index :sites, :alexa_global_rank
    remove_index :sites, :tools_count
  end
end
