module HasFavicon

  def self.included(receiver)
    receiver.class_eval do
      has_many :favicon, :primary_key => :uid, :foreign_key => :uid
    end
  end

  def full_favicon_url(style = "small")
    "http://s3.amazonaws.com/s.lineofthought.com/favicons/#{uid}/#{uid}.#{style}.png"
  end

  def small_favicon_url
    full_favicon_url("small")
  end
  
  def medium_favicon_url
    full_favicon_url("medium")
  end
end