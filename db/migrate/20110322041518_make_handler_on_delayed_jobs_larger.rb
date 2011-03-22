class MakeHandlerOnDelayedJobsLarger < ActiveRecord::Migration
  def self.up
    change_column :delayed_jobs, :handler, :text, :limit => 8.megabytes  
  end

  def self.down
    change_column :delayed_jobs, :handler, :text, :limit => 64.kilobytes
  end
end
