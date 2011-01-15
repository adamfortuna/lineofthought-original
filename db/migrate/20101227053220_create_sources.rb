class CreateSources < ActiveRecord::Migration
  def self.up
    create_table(:sources) do |t|
      t.timestamps
      t.string :title, :url
      t.text :description
      t.integer :sourceable_id
      t.string :sourceable_type
    end
    add_index :sources, [:sourceable_id, :sourceable_type]
  end

  def self.down
    drop_table :sources
  end
end
