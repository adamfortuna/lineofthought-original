class AddClaimColumnsToInvites < ActiveRecord::Migration
  def self.up
    add_column :invites, :user_id, :integer
  end

  def self.down
    remove_column :invites, :user_id
  end
end
