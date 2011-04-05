class AddCountersToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :lines_count, :integer, :default => 0
    add_column :users, :claimed_sites_count, :integer, :default => 0
    add_column :users, :claimed_tools_count, :integer, :default => 0
    
    User.readonly(false).all.each do |user|
      user.lines_count = user.usings.length
      user.claimed_sites_count = user.sites.length
      user.claimed_tools_count = user.tools.length
      user.save!
    end
  end

  def self.down
    remove_column :users, :usings_count
    remove_column :users, :claimed_sites_count
    remove_column :users, :claimed_tools_count
  end
end
