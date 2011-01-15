class AddAlexaRatingsToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :ranks_updated_at, :timestamp
    add_column :sites, :alexa_us_rank, :integer, :limit => 8
    add_column :sites, :alexa_global_rank, :integer, :limit => 8
    add_column :sites, :google_pagerank, :integer
  end

  def self.down
    remove_column :sites, :ranks_updated_at
    remove_column :sites, :alexa_us_rank
    remove_column :sites, :alexa_global_rank
    remove_column :sites, :google_pagerank
  end
end
