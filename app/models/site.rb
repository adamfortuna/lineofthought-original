require 'digest/md5'
class Site < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  has_friendly_id :full_uid, :use_slug => true
  acts_as_mappable
  include HasFavicon
  attr_accessor :skip_ranks

  searchable do
    text :title, :default_boost => 2
    string :lower_title do
      title.downcase
    end
    string :url
    text :description

    integer :tools_count
    integer :bookmarks_count
    integer :jobs_count
    integer :google_pagerank
    integer :alexa_global_rank do
      (alexa_global_rank.nil? || alexa_global_rank == 0) ? 100000000 : alexa_global_rank
    end
    
    boolean :featured, :using => :featured?
    boost { featured? ? 2.0 : 1.0 }
  end
  handle_asynchronously :solr_index
  
  validates_presence_of :url, :uid
  validate :validate_uri, :if => :url_changed?
  
  
  has_many :usings
  has_many :tools, :through => :usings
  belongs_to :link

  # Bookmarks
  has_many :annotations, :as => :annotateable
  has_many :bookmarks, :through => :annotations

  scope :popular, lambda { |limit| { :limit => limit, :order => "alexa_global_rank" }}
  scope :with_tools, lambda { |count| { :conditions => ["tools_count > ?", count] } }
  scope :featured, where(:featured => true).order("tools_count desc")
  scope :highlighted, order('alexa_global_rank').where(["tools_count > ? AND alexa_global_rank IS NOT NULL AND description IS NOT NULL and description != ''", 3])

  before_validation :default_title_to_domain, :on => :create

  composed_of :uri,
    :class_name => 'HandyUrl',
    :mapping    => %w(url to_s),
    :allow_nil  => true,
    :converter  => :new

  delegate :host, :path, :port, :domain, :full_uid, :to => :uri
  serialize :cached_tools
  serialize :cached_bookmarks
    
  def update_ranks!
    ranks = PageRankr.ranks(url, :alexa, :google) #=> {:alexa=>{:us=>1, :global=>1}, :google=>10}
    if ranks && ranks[:alexa][:us] != 0 && ranks[:alexa][:global] != 0 && ranks[:google] != 0
      self.update_attributes({ :alexa_us_rank => ranks[:alexa][:us], 
                               :alexa_global_rank => ranks[:alexa][:global], 
                               :google_pagerank => ranks[:google]})
    end
  end
  handle_asynchronously :update_ranks!
  after_create :update_ranks!, :if => :should_update_ranks?
  
  after_create :set_location_from_domain!
  def set_location_from_domain!
    existing_site = Site.find(:first, :conditions => ["uid = ? AND id != ? AND lat IS NOT NULL AND lng IS NOT NULL", self.uid, self.id])
    if existing_site
      self.update_attributes({
        :display_location => existing_site.display_location,
        :location => existing_site.location,
        :lat => existing_site.lat,
        :lng => existing_site.lng
      })
    else
      Timeout::timeout(10) do
        contact = [whois.technical_contact, 
                   whois.registrant_contact, 
                   whois.admin_contact].compact.first
        if contact
          location = [r.technical_contact.address, r.technical_contact.city, r.technical_contact.state, r.technical_contact.zip, r.technical_contact.country_code].compact
          display_location = [r.technical_contact.city, r.technical_contact.state, r.technical_contact.country_code].compact
          self.update_attributes({
            :display_location => display_location.join(", "),
            :location => location.join(", ")
          })
        end
      end
    end
  end
  handle_asynchronously :set_location_from_domain!
  
  
  def whois
    Whois.query(uri.domain_with_tld)
  end
  memoize :whois

  def update_cached_tools!
    self.cached_tools = []
    tools.limit(20).order("sites_count desc").each do |tool|
      self.cached_tools << { :name => tool.name, :param => tool.to_param }
    end
    save!
  end
  
  def update_cached_tools_in_background!
    update_cached_tools!
  end
  handle_asynchronously :update_cached_tools_in_background!
    
  def self.find_by_handy_url(handy_url)
    Site.find(:first, :conditions => ['url IN (?)', handy_url.variants.collect(&:to_s)])
  end
  
  def self.cached_count(reload = false)
    Rails.cache.fetch("site-cached_count", :expires_in => 15.minutes, :force => reload) do
      Site.count
    end
  end

  def self.autocomplete(q = "")
    search_results = search do
      any_of do
        with(:lower_title).starting_with(q.downcase)
        with(:url, q)
      end
    end
    search_results.results
  end

  
  def tools_hash
    self.tools.collect do |tool|
      { "id" => tool.id.to_s, "name" => "#{tool.name} (#{tool.sites_count})"}
    end
  end
  
  def update_bookmarks!
    self.cached_bookmarks = []
    self.bookmarks.recent.each do |bookmark|
      self.cached_bookmarks << { :id => bookmark.id, :title => bookmark.title, :param => bookmark.cached_slug }
    end
    save
  end

  def self.create_from_url(url)
    handy_url = HandyUrl.new(url)
    site = where(["uid = ?", handy_url.uid])
    return site.first.id unless site.blank?
    site = Site.create(:url => url, :title => handy_url.full_uid.capitalize)
    return site.id
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
  
  after_validation :create_or_update_link, :if => :url_changed?
  def create_or_update_link
    self.link = Link.find_or_create_by_url(url)
  end
  
  def default_title_to_domain
    self.title = full_uid unless self.title
  end

  before_validation :set_uid, :if => :url_changed?
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
  
  before_save :update_tools_cached_tools, :if => :title_changed?
  def update_tools_cached_tools
    tools.find_each(:batch_size => 200) do |tool|
      tool.update_cached_sites!
    end
  end
  handle_asynchronously :update_tools_cached_tools
  
  def should_update_ranks?
    !skip_ranks
  end
end