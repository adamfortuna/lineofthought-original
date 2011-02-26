class AddLocationsToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :display_location, :string
    add_column :sites, :location, :string
    add_column :sites, :lat, :decimal, :precision => 15, :scale => 10
    add_column :sites, :lng, :decimal, :precision => 15, :scale => 10
    
    add_index :sites, [:lat, :lng]
  end

  def self.down
    remove_column :sites, :lat
    remove_column :sites, :lng
    remove_column :sites, :location
    remove_index :sites, [:lat, :lng]
  end
end
