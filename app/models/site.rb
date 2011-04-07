require 'digest/md5'
class Site < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  has_friendly_id :full_uid, :use_slug => true
  has_paper_trail :only => [:description, :title, :location, :display_location]
  acts_as_mappable
  include HasFavicon
  attr_accessor :skip_ranks, :claimer  

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
    time :created_at
    
    boolean :featured, :using => :featured?
    boost { featured? ? 2.0 : 1.0 }
  end
  handle_asynchronously :solr_index
  
  validates_presence_of :url, :uid
  validate :validate_uri, :if => :url_changed?
  
  
  has_many :usings, :dependent => :destroy
  has_many :tools, :through => :usings#, :conditions => ["usings.deleted IS ?", nil]
  belongs_to :link

  # Bookmarks
  has_many :bookmark_annotations, :as => :annotateable, :dependent => :destroy
  has_many :bookmarks, :through => :bookmark_annotations
  
  # Claims
  has_many :claims, :as => :claimable, :dependent => :destroy
  has_many :users, :through => :claims

  scope :recent, order("created_at desc")
  scope :popular, lambda { |limit| { :limit => limit, :order => "alexa_global_rank" }}
  scope :with_tools, lambda { |count| { :conditions => ["tools_count > ?", count] } }
  scope :featured, where(:featured => true)
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
    
  def self.new_from_link(link)
    title_without_spaces = link.html_title.blank? ? "" : link.html_title.downcase.gsub(" ", "")
    if title_without_spaces.blank? || title_without_spaces.include?(link.uri.full_uid)
      title = link.uri.full_uid.capitalize
    else
      title = link.html_title || link.title
    end
    
    site = Site.new({
      :link => link,
      :url => link.url,
      :title => title,
      :description => link.description
    })
    site.set_location_from_whois
    site
  end
  
  def self.create_from_link(link, user = nil)
    site = new_from_link(link)
    site.claimer = user
    site.save
    site
  end
  
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
      set_location_from_whois
      save
    end
  end
  # handle_asynchronously :set_location_from_domain!
  
  
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
    
  def self.find_by_url(url)
    link, success = Link.find_or_create_by_domain(url)
    link ? link.site : nil
  end
  
  def self.cached_count(reload = false)
    Rails.cache.fetch("site-cached_count", :expires_in => 15.minutes, :force => reload) do
      Site.count
    end
  end

  def self.autocomplete(q = "")
    begin
      search_results = search do
        any_of do
          with(:lower_title).starting_with(q.downcase)
          with(:url, q)
        end
      end
      sites = search_results.results
    rescue Errno::ECONNREFUSED
      sites = Site.where(["title LIKE (?)", "#{q}%"])
    end
    sites
  end
  
  def tools_hash
    self.tools.collect(&:autocomplete_data)
  end
  
  def autocomplete_data
    { "title" => self.title, 
      "id" => self.id.to_s,
      "url" => self.url,
      "icon" => self.has_favicon? ? self.full_favicon_url : nil }    
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
  
  def set_location_from_whois(timeout = 5)
    Timeout::timeout(timeout) do
      contact = [self.whois.technical_contact, 
                 self.whois.registrant_contact, 
                 self.whois.admin_contact].compact.first
      if contact
        self.display_location = [contact.city.strip, 
                                 contact.state.strip, 
                                 contact.country_code.strip].compact.reject { |s| s.empty? }.join(", ")
        self.location = [contact.address.strip, 
                         contact.city.strip, 
                         contact.state.strip, 
                         contact.zip.strip, 
                         contact.country_code.strip].compact.reject { |s| s.empty? }.join(", ")
      end
    end
  rescue 
    # OK if not able to fetch whois info
  end
  
  def self.search_by_params(params)
    search = search do
      keywords params[:search] if params[:search]
      order_by(Site.order_for(params[:sort]).to_sym, Site.direction_for(params[:sort]).to_sym)
      paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 20)
    end
    puts "Loaded sites using solr"
    return search.results, search.hits, true
  rescue Errno::ECONNREFUSED
    puts "Unable to Connect to Solr to retreive sites. Falling back on SQL."
    sites = order([Site.order_for(params[:sort], "sql"), Site.direction_for(params[:sort])].join(" "))
            .paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 20)
    return sites, sites, false
  end
  
  def self.sql_order(order="")
    [Site.order_for(order, "sql"), Site.direction_for(order)].join(" ")
  end
  
  def self.order_for(order="", type="solr")
    field, direction = order.split("_")
    if type == "solr"
      case field
        when "alexa" then "alexa_global_rank"
        when "google" then "google_pagerank"
        when "tools" then "tools_count"
        when "sitename" then "lower_title"
        when "bookmarks" then "bookmarks_count"
        when "created" then "created_at"
        else "alexa_global_rank"
      end
    else
      case field
        when "alexa" then "coalesce(alexa_global_rank, 100000000)"
        when "google" then "google_pagerank"
        when "tools" then "tools_count"
        when "sitename" then "title"
        when "bookmarks" then "bookmarks_count"
        when "created" then "created_at"
        else "coalesce(alexa_global_rank, 100000000)"
      end
    end
  end
  
  def self.direction_for(order)
    order = order.split("_").last
    order = "asc" unless (order == "asc") || (order == "desc")
    return order
  end
  
  def claimed?
    claims.count > 0
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
  
  before_validation :set_url_from_link, :on => :create
  def set_url_from_link
    self.url = link.url if link
  end
  
  after_validation :create_or_update_link, :if => :url_changed?
  def create_or_update_link
    if !link || (link.url != self.url)
      self.link = Link.find_or_create_by_url(url)
    end
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
  
  after_create :create_initial_claim
  def create_initial_claim
    if claimer
      claim = claimer.claims.create({ :claimable => self })
      claim.bypass_and_claim!
    end
  end
end