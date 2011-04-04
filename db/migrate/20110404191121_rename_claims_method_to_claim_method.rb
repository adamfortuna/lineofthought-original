class RenameClaimsMethodToClaimMethod < ActiveRecord::Migration
  def self.up
    rename_column :claims, :method, :claim_method
  end

  def self.down
    rename_column :claims, :claim_method, :method
  end
end
