class AddUserIdToUsings < ActiveRecord::Migration
  def self.up
    add_column :usings, :user_id, :int
    add_index :usings, [:site_id, :user_id]
  end

  def self.down
    remove_column :usings, :user_id
    remove_index :usings, [:site_id, :user_id]
  end
end
