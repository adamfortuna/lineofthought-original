class AddSiteIdAndToolIdIndexToUsings < ActiveRecord::Migration
  def self.up
    add_index :usings, [:site_id, :tool_id]
  end

  def self.down
    remove_index :usings, [:site_id, :tool_id]
  end
end
