class ChangeArticlesCountDefault < ActiveRecord::Migration
  def self.up
    change_column :tools, :articles_count, :int, :default => 0
    change_column :sites, :articles_count, :int, :default => 0
  end

  def self.down
    change_column :tools, :articles_count, :int, :default => 0
    change_column :tools, :articles_count, :int, :default => 0
  end
end
