class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.timestamps
      t.string :title
      t.text :url, :description, :cached_tools, :cached_sites, :cached_connections
    end
    
    create_table :annotations do |t|
      t.timestamps
      t.string :annotateable_type
      t.integer :annotateable_id
      t.integer :article_id
      t.text :description
    end
  end

  def self.down
    drop_table :articles
    drop_table :annotations
  end
end