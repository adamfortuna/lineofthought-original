class AddUidToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :uid, :string
    Site.all.each do |site|
      site.update_attribute(:uid, site.uri.uid)
    end
  end

  def self.down
    remove_column :sites, :uid
  end
end
