class AddStatusToLink < ActiveRecord::Migration
  def self.up
    add_column :links, :status, :string
  end

  def self.down
    remove_column :links, :status
  end
end
