class RenameDeletedToDeletedAt < ActiveRecord::Migration
  def self.up
    rename_column :usings, :deleted, :deleted_at
    change_column :usings, :deleted_at, :datetime
    Using.update_all ["deleted_at = ?", Time.now], "deleted_at is not null"
  end

  def self.down
    change_column :usings, :deleted_at, :boolean
    rename_column :usings, :deleted_at, :deleted
  end
end
