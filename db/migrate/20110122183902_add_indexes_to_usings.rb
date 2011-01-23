class AddIndexesToUsings < ActiveRecord::Migration
  def self.up
    add_index :usings, :tool_id
    add_index :usings, :site_id
  end

  def self.down
    remove_index :usings, :tool_id
    remove_index :usings, :site_id
  end
end
