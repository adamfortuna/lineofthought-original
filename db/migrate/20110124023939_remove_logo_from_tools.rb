class RemoveLogoFromTools < ActiveRecord::Migration
  def self.up
    remove_column :tools, :logo_file_name
    remove_column :tools, :logo_content_type
    remove_column :tools, :logo_file_size
    remove_column :tools, :logo_updated_at
  end

  def self.down
    add_column :tools, :logo_file_name,    :string
    add_column :tools, :logo_content_type, :string
    add_column :tools, :logo_file_size,    :integer
    add_column :tools, :logo_updated_at,   :datetime
  end
end