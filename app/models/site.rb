class Site < ActiveRecord::Base
  has_friendly_id :full_uid, :use_slug => true
  acts_as_mappable
  include HasFavicon

  validates_presence_of :title, :url, :uid
  validate :validate_uri, :if => :url_changed?
  
  
  has_many :usings
  has_many :tools, :through => :usings

  # Articles
  has_many :annotations, :as => :annotateable
  has_many :articles, :through => :annotations

  scope :popular, lambda { |limit| { :limit => limit, :order => "alexa_global_rank" }}
  scope :with_tools, lambda { |count| { :conditions => ["tools_count > ?", count] } }

  before_validation :default_title_to_domain, :on => :create

  composed_of :uri,
    :class_name => 'FriendlyUrl',
    :mapping    => %w(url to_s),
    :allow_nil  => true,
    :converter  => :new

  delegate :host, :path, :port, :domain, :full_uid, :to => :uri
  serialize :top_tools
    
  def update_ranks!
    ranks = PageRankr.ranks(url, :alexa, :google) #=> {:alexa=>{:us=>1, :global=>1}, :google=>10}
    self.update_attributes({ :alexa_us_rank => ranks[:alexa][:us], 
                             :alexa_global_rank => ranks[:alexa][:global], 
                             :google_pagerank => ranks[:google]}) if ranks
  end
  handle_asynchronously :update_ranks!
  after_create :update_ranks!
  
  def update_top_tools!
    self.top_tools = { :generated => Time.now, :tools => [] }
    tools.where("sites_count > 0").limit(20).order("sites_count desc").each do |tool|
      self.top_tools[:tools] << { :name => tool.name, :param => tool.to_param }
    end
    save
  end
  
  def update_top_tools_in_background!
    update_top_tools!
  end
  handle_asynchronously :update_top_tools_in_background!
    
  def self.find_by_friendly_url(friendly_url)
    Site.find(:first, :conditions => ['url IN (?)', friendly_url.variants.collect(&:to_s)])
  end
  
  def self.cached_count(reload = false)
    Rails.cache.fetch("site-cached_count", :expires_in => 15.minutes, :force => reload) do
      Site.count
    end
  end
  
  def tools_hash
    self.tools.collect do |tool|
      { "id" => tool.id.to_s, "name" => "#{tool.name} (#{tool.sites_count})"}
    end
  end
  
  def update_articles!
    self.cached_articles = []
    self.articles.each do |article|
      self.cached_articles << { :id => article.id, :title => article.title}
    end
    save
  end

  def load_by_url
    self.title ||= loader.title
    self.description = loader.description if self.description.blank?
    set_uid
  end

  def loader
    @loader ||= Loader.new(url)
  end
    
  private
  
  def validate_uri
    if uri.to_s !~ Util::URL_HTTP_OPTIONAL || !uri.valid? # valid?
      errors.add(:uri, "is not a valid URL")
    else
      conditions = if new_record?
                     ['url IN (?)', uri.variants.collect(&:to_s)]
                   else
                     ['url IN (?) AND id != ?', uri.variants.collect(&:to_s), id]
                   end
      errors.add(:uri, "is already in use") if self.class.exists?(conditions)
    end
  end
  
  def default_title_to_domain
    self.title = full_uid unless self.title
  end
  
  before_validation :set_uid, :on => :create
  before_validation :set_uid, :on => :update, :if => :url_changed?
  def set_uid
    self.uid = self.uri.uid
  end
  
  after_save :update_lat_and_lng, :if => :location_changed?
  def update_lat_and_lng
    geo = Geokit::Geocoders::MultiGeocoder.geocode(location)
    errors.add(:address, "Could not Geocode address") if !geo.success
    self.lat, self.lng = geo.lat, geo.lng if geo.success
    save
  end
  handle_asynchronously :update_lat_and_lng
end