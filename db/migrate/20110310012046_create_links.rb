class CreateLinks < ActiveRecord::Migration
  def self.up
    
    create_table :favicons do |t|
      t.string :original_url, :uid, :favicon_file_name, :favicon_content_type
      t.integer :favicon_file_size
      t.datetime :favicon_updated_at
    end
    add_index :favicons, :uid
    
    create_table :links do |t|
      t.timestamps
      t.string :original_url, :normalized_url, :destination_url, :normalized_root_url, :uid
      t.integer :clicks_count, :default => 0
      t.string :title, :author
      t.text :description, :html, :html_body, :body
      t.text :cached_keywords, :cached_links
      t.string :feed
      t.datetime :date_posted
      t.boolean :has_favicon, :default => false
    end
    add_index :links, :normalized_url
    add_index :links, :date_posted
    
    add_column :sites, :has_favicon, :boolean, :default => false
    add_column :tools, :has_favicon, :boolean, :default => false
  end

  def self.down
    drop_table :favicons
    drop_table :links
    
    remove_column :sites, :has_favicon
    remove_column :tools, :has_favicon
  end
end
