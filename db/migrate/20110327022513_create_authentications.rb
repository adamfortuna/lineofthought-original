class CreateAuthentications < ActiveRecord::Migration
  def self.up
    create_table :authentications, :force => true do |t|
      t.column :user_id, :int
      t.column :provider, :string
      t.column :uid, :string
    end
    add_index :authentications, [:provider, :uid]
    
    add_column :users, :time_zone, :string
  end

  def self.down
    drop_table :authentications
    remove_column :users, :time_zone
  end
end
