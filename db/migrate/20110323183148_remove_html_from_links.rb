class RemoveHtmlFromLinks < ActiveRecord::Migration
  def self.up
    remove_column :links, :html
    remove_column :links, :html_body
    remove_column :links, :body
  end

  def self.down
    add_column :links, :html, :text
    add_column :links, :html_body, :text
    add_column :links, :body, :text
  end
end
