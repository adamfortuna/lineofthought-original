class RemoveParsedFromLinks < ActiveRecord::Migration
  def self.up
    remove_column :links, :parsed
  end

  def self.down
    add_column :links, :parsed, :default => false
    Link.update_all "parsed=true"
  end
end
