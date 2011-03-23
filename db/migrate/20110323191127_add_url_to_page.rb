class AddUrlToPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :url, :text
    Link.where("page_id is not null").each do |link|
      link.page.update_attribute(:url, link.url)
    end
  end

  def self.down
    remove_column :pages, :url
  end
end
