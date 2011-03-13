class Favicon < ActiveRecord::Base
  has_attached_file :favicon,
                    :styles => { 
                      :small => { :geometry => "16x16>", :format => 'png' },
                      :large => { :geometry => "48x48>", :format => 'png' }
                    },
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root}/config/s3.yml",
                    :path => "/favicons/:uid.:style.:extension"
  validates_presence_of :original_url

  composed_of :uri,
    :class_name => 'FriendlyUrl',
    :mapping    => %w(original_url to_s),
    :allow_nil  => true,
    :converter  => :new


  def self.create_by_favion_url(favicon, uri)
    parsed_favicon_url = favicon || "#{uri.scheme}://#{uri.host}/favicon.ico"
    if Util.relative_url?(parsed_favicon_url)
      favicon = "/#{favicon}" unless favicon[0] == "/"
      parsed_favicon_url = "#{uri.scheme}://#{uri.host}#{favicon}"
    end
    favicon = Favicon.find_by_original_url(parsed_favicon_url)
    favicon || Favicon.create({:original_url => parsed_favicon_url, :uid => uri.uid})
  end

  def download_favicon!
    Timeout::timeout(20) do
      fav = self.favicon = download_remote_image
      if fav.nil? || !save
        Favicon.delete_all "id=#{self.id}"
      end
    end
  end
  handle_asynchronously :download_favicon!
  after_save :download_favicon!, :if => :original_url_changed?
  
  private  
  def original_url_provided?
    !self.original_url.blank?
  end

  def download_remote_image
    io = open(URI.parse(original_url))
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
  end
  
  after_save :update_associated_items, :if => :favicon_file_name_changed?
  def update_associated_items
    Site.update_all "has_favicon=1", ["uid = ?", uid]
    Tool.update_all "has_favicon=1", ["uid = ?", uid]
    Link.update_all "has_favicon=1", ["uid = ?", uid]
  end
  
end