class AddCodeToPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :code, :integer
    add_column :pages, :success, :boolean, :default => false
  end

  def self.down
    remove_column :pages, :code
    remove_column :pages, :success
  end
end
