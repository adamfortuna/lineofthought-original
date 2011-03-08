class AddKeywordToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :keyword, :string
  end

  def self.down
    remove_column :categories, :keyword
  end
end
