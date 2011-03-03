class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.timestamps
      t.string :status, :title, :url, :company
      t.text :description, :how_to_apply
      t.text :cached_sites, :cached_tools
      t.datetime :posted_at

      t.string :logo, :display_location, :location
      t.string :lat, :decimal, :precision => 15, :scale => 10
      t.string :lng, :decimal, :precision => 15, :scale => 10
      t.integer :views_count
    end
    add_index :jobs, [:lat, :lng]


    create_table :workables do |t|
      t.integer :job_id
      t.string :workable_type
      t.string :workable_id
      t.text :description
    end
    add_index :workables, :job_id
    add_index :workables, [:workable_type, :workable_id]    
  end

  def self.down
    drop_table :jobs
    drop_table :workables
  end
end
