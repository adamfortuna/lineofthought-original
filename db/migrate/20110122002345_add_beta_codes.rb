class AddBetaCodes < ActiveRecord::Migration
  def self.up
    create_table :invites do |t|
      t.string :code
      t.integer :max_count, :default => 1
      t.integer :users_count, :default => 0
      t.timestamp :expire_date
    end
    add_index :invites, :code
    
    add_column :users, :invite_code, :string
  end

  def self.down
    drop_table :sources
    remove_column :users, :invite_code
  end
end
