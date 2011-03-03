class AddIndexToJobsCount < ActiveRecord::Migration
  def self.up
    add_index :tools, :jobs_count
    add_index :sites, :jobs_count
  end

  def self.down
    remove_index :tools, :jobs_count
    remove_index :sites, :jobs_count
  end
end
