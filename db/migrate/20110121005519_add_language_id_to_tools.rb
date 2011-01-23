class AddLanguageIdToTools < ActiveRecord::Migration
  def self.up
    add_column :tools, :language_id, :int
  end

  def self.down
    remove_column :tools, :language_id
  end
end
