class CleanupLinks < ActiveRecord::Migration
  def self.up
    remove_column :links, :destination_url
    rename_column :links, :root_canonical, :uid_with_subdomain
    
    create_table :pages do |t|
      t.timestamps
      t.text :html, :limit => 8.megabytes
    end
    
    add_column :links, :page_id, :integer
    
    Link.where("html is not null").all.each do |link|
      link.page = Page.create(:html => link.html)
      link.uid_with_subdomain = link.uri.uid_with_subdomain
      link.save
    end
  end

  def self.down
    add_column :links, :destination_url, :string
    rename_column :links, :uid_with_subdomain, :root_canonical
    drop_table :pages
    remove_column :links, :page_id
  end
end
