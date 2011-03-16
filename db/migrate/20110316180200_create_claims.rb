class CreateClaims < ActiveRecord::Migration
  def self.up
    create_table :claims do |t|
      t.datetime :created_at
      t.integer :user_id, :claimable_id
      t.string :claimable_type
    end
    add_index :claims, :user_id
    add_index :claims, [:claimable_id, :claimable_type]
    
    add_column :users, :cached_site_claims, :text
    add_column :users, :cached_tool_claims, :text
  end

  def self.down
    drop_table :claims
    remove_column :users, :cached_site_claims
    remove_column :users, :cached_tool_claims
  end
end
