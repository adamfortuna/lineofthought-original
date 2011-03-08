class AddFaviconToSitesAndTools < ActiveRecord::Migration
  def self.up
    add_column :sites, :favicon, :string
    add_column :tools, :favicon, :string
  end

  def self.down
    remove_column :sites, :favicon
    remove_column :tools, :favicon
  end
end
