class AddRootCanonicalToLinks < ActiveRecord::Migration
  def self.up
    add_column :links, :root_canonical, :string
    add_index :links, :root_canonical
    Link.all.each do |link|
      link.update_attribute(:root_canonical, link.uri.root_canonical)
    end
  end

  def self.down
    remove_column :links, :root_canonical
  end
end
