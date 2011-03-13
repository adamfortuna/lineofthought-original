class RemoveFaviconFromSitesAndTools < ActiveRecord::Migration
  def self.up
    remove_column :tools, :favicon
    remove_column :sites, :favicon
  end

  def self.down
    add_column :tools, :favicon, :string
    add_column :sites, :favicon, :string
  end
end
