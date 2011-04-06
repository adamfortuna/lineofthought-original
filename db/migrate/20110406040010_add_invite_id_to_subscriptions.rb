class AddInviteIdToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :invite_id, :integer
    add_column :subscriptions, :invite_sent_at, :datetime
  end

  def self.down
    remove_column :subscriptions, :invite_id
    remove_column :subscriptions, :invite_sent_at
  end
end
