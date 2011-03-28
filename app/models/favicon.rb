class Favicon < ActiveRecord::Base
  has_attached_file :favicon,
                    :styles => { 
                      :small => { :geometry => "16x16>", :format => 'png' },
                      :large => { :geometry => "48x48>", :format => 'png' }
                    },
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root}/config/s3.yml",
                    :path => "/favicons/:uid/:uid.:style.:extension"
  validates_presence_of :url

  composed_of :uri,
    :class_name => 'HandyUrl',
    :mapping    => %w(url to_s),
    :allow_nil  => true,
    :converter  => :new


  def self.create_by_favicon_url(favicon, uri)
    favicon = Favicon.find_by_uri(:uri)
    if favicon
      favicon.update_associated_items
      return true
    end
    parsed_favicon_url = favicon || "#{uri.scheme}://#{uri.host}/favicon.ico"
    if Util.relative_url?(parsed_favicon_url)
      favicon = "/#{favicon}" unless favicon[0] == "/"
      parsed_favicon_url = "#{uri.scheme}://#{uri.host}#{favicon}"
    end
    favicon = Favicon.find_by_url(parsed_favicon_url)
    favicon || Favicon.create({ :url => parsed_favicon_url, :uid => uri.uid })
  end

  def download_favicon!
    Timeout::timeout(20) do
      fav = self.favicon = download_remote_image
      # If not able to save the favicon, just delete it from favicons
      if fav.nil? || !save
        Favicon.delete_all "id=#{self.id}" 
      else
        update_associated_items
      end
    end
  end
  handle_asynchronously :download_favicon!
  after_save :download_favicon!, :if => :url_changed?

  def update_associated_items
    Site.update_all "has_favicon=true", ["uid = ?", uid]
    Tool.update_all "has_favicon=true", ["uid = ?", uid]
    Link.update_all "has_favicon=true", ["uid = ?", uid]
    Bookmark.update_all "has_favicon=true", ["uid = ?", uid]
  end
  handle_asynchronously :update_associated_items
    
  private
  
  def download_remote_image
    io = open(URI.parse(url))
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
  end
end