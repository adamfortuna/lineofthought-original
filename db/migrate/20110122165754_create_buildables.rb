class CreateBuildables < ActiveRecord::Migration
  def self.up
    create_table :buildables do |t|
      t.integer :tool_id, :category_id
    end
    add_index :buildables, :tool_id
    add_index :buildables, :category_id

    remove_column :tools, :category_id
  end

  def self.down
    drop_table :buildables
    add_column :tools, :category_id, :integer
  end
end
