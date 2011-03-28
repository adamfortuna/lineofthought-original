class AddHtmlTitleToLinks < ActiveRecord::Migration
  def self.up
    add_column :links, :html_title, :string
  end

  def self.down
    remove_column :links, :html_title, :string
  end
end
