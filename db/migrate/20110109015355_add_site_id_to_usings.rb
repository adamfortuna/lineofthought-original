class AddSiteIdToUsings < ActiveRecord::Migration
  def self.up
    add_column :usings, :site_id, :integer, :null => false
    Using.update_all "site_id=usable_id"
    remove_column :usings, :usable_id
    remove_column :usings, :usable_type
  end

  def self.down
    add_column :usings, :usable_id, :int
    add_column :usings, :usable_type, :string
    Using.update_all "usable_type='Site', usable_id=site_id"
    remove_column :usings, :site_id
  end
end
