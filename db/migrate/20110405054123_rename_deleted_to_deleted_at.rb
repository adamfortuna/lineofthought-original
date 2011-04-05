class RenameDeletedToDeletedAt < ActiveRecord::Migration
  def self.up
    add_column :usings, :deleted_at, :datetime
    Using.update_all ["deleted_at = ?", Time.now], "deleted is not null"
    remove_column :usings, :deleted
  end

  def self.down
    add_column :usings, :deleted, :boolean
    Using.update_all ["deleted = ?", true], "deleted_at is not null"
    remove_column :usings, :deleted_at
  end
end
