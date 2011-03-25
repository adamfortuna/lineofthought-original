module HasFavicon

  def self.included(receiver)
    receiver.class_eval do
      has_many :favicon, :primary_key => :uid, :foreign_key => :uid
    end
  end

  def full_favicon_url(style = "small")
    "https://d1mr7he6yibwdu.cloudfront.net/favicons/#{uid}/#{uid}.#{style}.png"
  end

  def small_favicon_url
    full_favicon_url("small")
  end
  
  def medium_favicon_url
    full_favicon_url("medium")
  end
end