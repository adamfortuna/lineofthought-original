class AddParsedToLinks < ActiveRecord::Migration
  def self.up
    add_column :links, :parsed, :boolean, :default => false
  end

  def self.down
    remove_column :links, :parsed
  end
end
