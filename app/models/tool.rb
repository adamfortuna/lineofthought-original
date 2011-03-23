require 'csv'
class Tool < ActiveRecord::Base
  has_friendly_id :name, :use_slug => true
  include HasFavicon

  searchable do
    text :name, :default_boost => 2
    string :name
    string :url
    text :description
    
    integer :sites_count
    integer :bookmarks_count
    integer :jobs_count
    
    text :categories do
      cached_categories.map { |category| category[:name] }
    end
    
    boolean :featured, :using => :featured?
    boost { featured? ? 2.0 : 1.0 }
  end
    
  attr_accessible :name, :url, :description, :category_ids, :language_id
  
  belongs_to :language, :class_name => 'Tool'
  has_many :buildables, :dependent => :destroy
  has_many :categories, :through => :buildables
  has_many :usings, :dependent => :destroy
  
  has_many :sites, :through => :usings
  
  # Used to get all links that are considered this Tools main pages
  has_many :sources, :as => :sourceable
  has_many :links, :through => :sources
  
  # Bookmarks
  has_many :annotations, :as => :annotateable, :dependent => :destroy
  has_many :bookmarks, :through => :annotations

  accepts_nested_attributes_for :categories
  accepts_nested_attributes_for :sources

  validates_presence_of :url
  validates_uniqueness_of :url
  validate :validate_uri

  scope :languages, :conditions => "buildables.category_id = categories.id AND categories.name='Programming Langauge'", :joins => { :buildables => :category }
  scope :featured, where(:featured => true).order("sites_count desc")

  serialize :cached_sites
  serialize :cached_categories
  serialize :cached_language
  serialize :cached_bookmarks

  before_save :update_cached_categories, :if => :categories_changed?
  after_save :update_sites_cached_tools, :if => :name_changed?
  
  composed_of :uri,
    :class_name => 'HandyUrl',
    :mapping    => %w(url to_s),
    :allow_nil  => true,
    :converter  => :new
  delegate :host, :path, :port, :domain, :full_uid, :uid, :to => :uri

  def self.for_autocomplete(count = 20)
    order('sites_count desc').limit(count).collect { |t| {"id" => t.id.to_s, "name" => "#{t.name}#{" (#{t.cached_language[:name]})" if t.cached_language}", "description" => "(#{t.combined_category_names.join(", ")})"}}
  end
  
  def combined_category_names
    combined_categories.collect { |s| s[:name] }
  end
  
  def combined_categories
    ([self.cached_language] + self.cached_categories).compact
  end
  
  def add_sites!(csv)
    transaction do
      CSV.parse(csv) do |row|
        self.add_site!(row[0], row[1..row.length].join(", "))
      end
    end
  end
  handle_asynchronously :add_sites!
  
  def add_site!(url, description = nil)
    handy_url = HandyUrl.new(url)
    if site = Site.find_by_handy_url(handy_url)
      using = self.usings.find_by_site_id(site.id)
    else
      site = Site.new({ :uri => url })
      site.load_by_url
      site.save
    end
  
    description.strip! if description
    self.usings.create( {:site => site, :description => description }) unless using
  end
  handle_asynchronously :add_site!
  
  def update_cached_sites!
    self.cached_sites = []
    sites.limit(20).order("google_pagerank desc").each do |site|
      self.cached_sites << { :name => site.title, :param => site.to_param }
    end
    save!
  end

  def update_cached_sites_in_background!
    update_cached_sites!
  end
  handle_asynchronously :update_cached_sites_in_background!


  def update_cached_categories
    self.cached_categories = []
    cats = new_record? ? self.categories : self.categories.order(:name)
    cats.each do |category|
      self.cached_categories << { :name => category.name, :param => category.to_param }
    end
    self.cached_language = nil
    self.cached_language = { :name => language.name, :param => language.to_param } if language
  end

  def update_cached_categories!
    update_cached_categories
    save!
  end
  
  def update_bookmarks!
    self.cached_bookmarks = []
    self.bookmarks.recent.limit(5).each do |bookmark|
      self.cached_bookmarks << { :id => bookmark.id, :title => bookmark.title, :param => bookmark.cached_slug }
    end
    save
  end
    
  def self.find_by_handy_url(handy_url)
    Tool.find(:first, :conditions => ['url IN (?)', handy_url.variants.collect(&:to_s)])
  end

  def update_sites_cached_tools
    return if sites_count <= 0
    sites.find_each(:batch_size => 200) do |site|
      site.update_cached_tools!
    end
  end
  handle_asynchronously :update_sites_cached_tools


  def self.new_from_link(link)
    tool = Tool.new
    tool.url = link.url
    tool.categories = link.categories
    if link.cached_keywords && link.cached_keywords.length > 0
      tool.name = link.cached_keywords.first.first
    else
      tool.name = link.title
    end
    tool.description = link.description
    tool
  end
  
  def sites_hash
    self.sites.collect do |site|
      { "id" => site.id.to_s, "name" => "#{site.title} (#{site.url})"}
    end
  end
  

  private
  def categories_changed?
    true
  end

  def validate_uri
    errors.add(:url, "is not a valid URL") if !uri.valid?
    errors.empty?
  end
  
  after_save :create_or_update_link, :if => :url_changed?
  def create_or_update_link
    link = Link.find_or_create_by_url(url)
    self.sources.create({:link => link})
  end
  
  after_validation :check_for_favicon, :if => :uid_changed?
  def check_for_favicon
    self.has_favicon = true if Favicon.exists?(:uid => self.uid)
  end
  
  before_validation :set_uid, :if => :url_changed?
  def set_uid
    self.uid = self.uri.uid
  end
end