class AddDeletedAtToUsings < ActiveRecord::Migration
  def self.up
    add_column :usings, :deleted, :boolean
  end

  def self.down
    remove_column :usings, :deleted
  end
end
