class AddStatusUpdatedAtToClaims < ActiveRecord::Migration
  def self.up
    add_column :claims, :status_updated_at, :datetime
    Claim.update_all ["status_updated_at = ?", Time.now]
  end

  def self.down
    remove_column :claims, :status_updated_at
  end
end
