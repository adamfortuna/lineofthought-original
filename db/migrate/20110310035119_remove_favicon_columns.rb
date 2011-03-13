class RemoveFaviconColumns < ActiveRecord::Migration
  def self.up
    remove_column :tools, :favicon_file_name 
    remove_column :tools, :favicon_content_type
    remove_column :tools, :favicon_file_size 
    remove_column :tools, :favicon_updated_at                                       
    rename_column :tools, :favicon_url, :favicon
    remove_column :sites, :favicon_file_name   
    remove_column :sites, :favicon_content_type
    remove_column :sites, :favicon_file_size   
    remove_column :sites, :favicon_updated_at
    rename_column :sites, :favicon_url, :favicon
    remove_column :articles, :favicon_url
    remove_column :articles, :favicon_file_name
    remove_column :articles, :favicon_content_type 
    remove_column :articles, :favicon_file_size  
    remove_column :articles, :favicon_updated_at
    add_column :articles, :has_favicon, :boolean, :default => false
    add_column :tools, :uid, :string
  end

  def self.down
    add_column :tools, :favicon_file_name,    :string
    add_column :tools, :favicon_content_type, :string
    add_column :tools, :favicon_file_size,    :integer
    add_column :tools, :favicon_updated_at,   :datetime

    add_column :sites, :favicon_file_name,    :string
    add_column :sites, :favicon_content_type, :string
    add_column :sites, :favicon_file_size,    :integer
    add_column :sites, :favicon_updated_at,   :datetime

    add_column :articles, :favicon_url,          :string
    add_column :articles, :favicon_file_name,    :string
    add_column :articles, :favicon_content_type, :string
    add_column :articles, :favicon_file_size,    :integer
    add_column :articles, :favicon_updated_at,   :datetime
  end
end
