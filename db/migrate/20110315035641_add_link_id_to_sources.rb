class AddLinkIdToSources < ActiveRecord::Migration
  def self.up
    add_column :sources, :link_id, :int
    remove_column :sources, :url
    remove_column :sources, :description
    remove_column :sources, :updated_at
  end

  def self.down
    remove_column :sources, :link_id
    add_column :sources, :url, :string
    add_column :sources, :description, :text
    add_column :sources, :updated_at, :datetime
  end
end
