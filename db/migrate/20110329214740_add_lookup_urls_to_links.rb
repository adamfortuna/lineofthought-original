class AddLookupUrlsToLinks < ActiveRecord::Migration
  def self.up
    add_column :links, :lookup_urls, :text
    
    Link.all.each do |link|
      link.update_attribute(:lookup_urls, [link.uri.to_s, link.original_uri.to_s].compact.uniq)
    end
  end

  def self.down
    remove_column :links, :lookup_urls
  end
end
