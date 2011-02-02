class AddCachedLanguageToTools < ActiveRecord::Migration
  def self.up
    add_column :tools, :cached_language, :string
  end

  def self.down
    remove_column :tools, :cached_lanuage
  end
end
