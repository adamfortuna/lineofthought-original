class AddHtmlTitleAndDescriptionToLinks < ActiveRecord::Migration
  def self.up
    add_column :links, :lede, :text
  end

  def self.down
    remove_column :links, :lede, :text
  end
end
