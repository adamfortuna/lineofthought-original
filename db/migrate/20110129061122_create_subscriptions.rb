class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.timestamps
      t.string :email, :referrer
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
