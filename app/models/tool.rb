require 'csv'
class Tool < ActiveRecord::Base
  has_friendly_id :name, :use_slug => true
  has_paper_trail :only => [:description, :name, :url, :language_id]
  include HasFavicon
  attr_accessor :claimer

  searchable do
    text :name, :default_boost => 2
    string :lower_name do
      name.downcase
    end

    string :url
    text :description

    integer :sites_count
    integer :bookmarks_count
    integer :jobs_count
    
    text :categories do
      cached_categories.map { |category| category[:name] }
    end
    
    time :created_at
    boolean :featured, :using => :featured?
    boost { featured? ? 2.0 : 1.0 }
  end
  handle_asynchronously :solr_index
    
  attr_accessible :name, :url, :description, :category_ids, :language_id, :link_id, :claimer, :categories, :link
  
  belongs_to :language, :class_name => 'Tool'
  has_many :buildables, :dependent => :destroy
  has_many :categories, :through => :buildables
  has_many :usings, :dependent => :destroy
  has_many :sites, :through => :usings#, :conditions => ["usings.deleted IS ?", nil]
  
  # Used to get all links that are considered this Tools main pages
  has_many :sources, :as => :sourceable, :dependent => :destroy
  has_many :links, :through => :sources
  belongs_to :link
  
  # Bookmarks
  has_many :annotations, :class_name => "BookmarkAnnotation", :as => :annotateable, :dependent => :destroy
  has_many :bookmarks, :through => :annotations, :conditions => "parent_id is null"
  has_many :bookmark_users, :through => :annotations, :source => :bookmark, :class_name => "BookmarkUser", :conditions => "parent_id is not null"

  # Claims
  has_many :claims, :as => :claimable, :dependent => :destroy
  has_many :users, :through => :claims

  accepts_nested_attributes_for :categories
  accepts_nested_attributes_for :sources

  validates_presence_of :name
  validates_uniqueness_of :url, :allow_nil => true
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
    begin
      raise Errno::ECONNREFUSED if !Settings.use_solr
      search = nil
      Timeout::timeout(1) do
        search = search do
          order_by(:sites_count, :desc)
          paginate(:page => 1, :per_page => 15)
        end
      end
      tools = search.results
    rescue Errno::ECONNREFUSED, Timeout::Error
      tools = order("sites_count desc").paginate(:page => 1, :per_page => 15)
    end    
    tools.collect { |t| {"id" => t.id.to_s, "name" => "#{t.name}#{" (#{t.cached_language[:name]})" if t.cached_language}", "description" => "(#{t.combined_category_names.join(", ")})"}}
  end
  
  def self.autocomplete(q = "")
    begin
      raise Errno::ECONNREFUSED if !Settings.use_solr
      search = nil
      Timeout::timeout(1) do      
        search_results = search do
          any_of do
            with(:lower_name).starting_with(q.downcase)
            with(:url, q)
          end
        end
      end
      tools = search_results.results
    rescue Errno::ECONNREFUSED, Timeout::Error
      tools = Tool.where(["name LIKE (?)", "#{q}%"])
    end
    tools
  end
  
  def combined_category_names
    combined_categories.collect { |s| s[:name] }
  end
  
  def combined_categories
    ([self.cached_language] + self.cached_categories).compact
  end
  
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
    
  def self.find_by_url(url)
    link, success = Link.find_by_entered_url(url)
    link ? link.tool : nil
  end

  def update_sites_cached_tools
    return if sites_count <= 0
    sites.find_each(:batch_size => 200) do |site|
      site.update_cached_tools!
    end
  end
  handle_asynchronously :update_sites_cached_tools


  def self.new_from_link(link)
    tool = Tool.new({
      :url => link.url,
      :categories => link.categories,
      :description => link.description,
      :link => link,
      :link_id => link.id
    })
    tool.name = link.title
    tool
  end
  
  def sites_hash
    self.sites.collect(&:autocomplete_data)
  end
  
  def autocomplete_data
    { "name" => self.name, 
      "id" => self.id.to_s,
      "url" => self.url,
      "categories" => self.cached_categories.collect { |c| c[:name]}.join(", "),
      "icon" => self.has_favicon? ? self.full_favicon_url : nil }    
  end
  
  def self.search_by_params(params)
    raise Errno::ECONNREFUSED if !Settings.use_solr
    search = nil
    Timeout::timeout(1) do
      search = search do
        keywords params[:search] if params[:search]
        keywords params[:category], :fields => [:categories] if params[:category]
        order_by(Tool.order_for(params[:sort]).to_sym, Tool.direction_for(params[:sort]).to_sym)
        paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 20)
      end
    end
    # puts "Loaded tools using solr"
    return search.results, search.hits, true
  rescue Errno::ECONNREFUSED, Timeout::Error
    # puts "Unable to Connect to Solr to retreive tools. Falling back on SQL."
    if params[:category]
      tools = joins(:categories)
              .where(["categories.name = ?", params[:category]])
              .order(Tool.sql_order(params[:sort]))
              .paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 20)
    else
      tools = order(Tool.sql_order(params[:sort]))
              .paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 20)
    end
            
    return tools, tools, false
  end
  
  def self.sql_order(order="")
    [Tool.order_for(order, "sql"), Tool.direction_for(order)].join(" ")
  end
  
  def self.order_for(order="", type="solr")
    field, direction = order.split("_")
    if type == "solr"
      case field
        when "sites" then "sites_count"
        when "toolname" then "lower_name"
        when "bookmarks" then "bookmarks_count"
        when "jobs" then "jobs_count"
        when "created" then "created_at"
        else "sites_count"
      end
    else
      case field
        when "sites" then "sites_count"
        when "toolname" then "name"
        when "bookmarks" then "bookmarks_count"
        when "jobs" then "jobs_count"
        when "created" then "created_at"
        else "sites_count"
      end
    end
  end
  
  def self.direction_for(order)
    order = order.split("_").last
    order = "desc" unless (order == "asc") || (order == "desc")
    return order
  end
  
  def claimed?
    false
  end

  private
  def categories_changed?
    true
  end

  def validate_uri
    return true if url.blank?
    errors.add(:url, "is not a valid URL") if !uri.valid?
    errors.empty?
  end
  
  before_validation :create_or_update_link, :if => :url_changed?
  def create_or_update_link
    self.link = Link.find_or_create_by_url(url)
  end
  
  after_validation :check_for_favicon, :if => :uid_changed?
  def check_for_favicon
    self.has_favicon = true if Favicon.exists?(:uid => self.uid)
  end
  
  before_validation :set_uid, :if => :url_changed?
  def set_uid
    self.uid = self.uri.uid unless self.url.blank?
  end
  
  after_create :create_initial_claim
  def create_initial_claim
    if claimer
      claim = claimer.claims.create({ :claimable => self })
      claim.bypass_and_claim!
    end
    return true
  rescue Exception => e
    return false
  end
end