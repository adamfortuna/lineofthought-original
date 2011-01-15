class SetupInitialTables < ActiveRecord::Migration
  def self.up
    create_table(:categories) do |t|
      t.string :cached_slug, :name
    end
    add_index :categories, :cached_slug, :unique => true


    create_table(:tools) do |t|
      t.timestamps
      t.string :cached_slug, :name, :url
      t.integer :category_id
      t.text :description
    end
    add_index :tools, :cached_slug, :unique => true
    add_index :tools, :category_id


    create_table(:sites) do |t|
      t.timestamps
      t.string :cached_slug, :title, :url
      t.text :description
    end
    add_index :sites, :cached_slug, :unique => true


    create_table(:usings) do |t|
      t.timestamps
      t.integer :tool_id
      t.integer :usable_id
      t.string :usable_type
      t.text :description
    end
    add_index :usings, [:usable_id, :usable_type]


    create_table(:owners) do |t|
      t.timestamps
      t.integer :user_id
      t.integer :ownable_id
      t.string :ownable_type
      t.integer :level
    end
    add_index :owners, [:user_id, :ownable_id, :ownable_type]
  end

  def self.down
    drop_table :categories
    drop_table :tools
    drop_table :sites
    drop_table :usings
    drop_table :owners
  end
end