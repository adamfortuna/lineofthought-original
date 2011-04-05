class AddUrlToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :url, :string
  end

  def self.down
    remove_column :subscriptions, :url
  end
end
