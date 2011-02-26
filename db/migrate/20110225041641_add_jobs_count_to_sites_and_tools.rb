class AddJobsCountToSitesAndTools < ActiveRecord::Migration
  def self.up
    add_column :tools, :jobs_count, :integer, :default => 0
    add_column :sites, :jobs_count, :integer, :default => 0
  end

  def self.down
    remove_column :tools, :jobs_count
    remove_column :sites, :jobs_count
  end
end
