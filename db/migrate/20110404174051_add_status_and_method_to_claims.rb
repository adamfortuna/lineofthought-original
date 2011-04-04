class AddStatusAndMethodToClaims < ActiveRecord::Migration
  def self.up
    add_column :claims, :status, :string
    add_column :claims, :method, :string
    Claim.update_all "status='verified', method='tag'"
  end

  def self.down
    remove_column :claims, :method
    remove_column :claims, :status
  end
end
