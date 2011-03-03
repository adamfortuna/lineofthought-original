require 'csv'
class Tool < ActiveRecord::Base

  attr_accessible :name, :url, :description, :category_ids, :language_id
  attr_accessor :csv
  has_friendly_id :name, :use_slug => true
  
  belongs_to :language, :class_name => 'Tool'
  has_many :buildables, :dependent => :destroy
  has_many :categories, :through => :buildables
  has_many :usings, :dependent => :destroy
  has_many :sites, :through => :usings
  has_many :sources, :as => :sourceable

  # Articles
  has_many :annotations, :as => :annotateable, :dependent => :destroy
  has_many :articles, :through => :annotations

  accepts_nested_attributes_for :categories
  accepts_nested_attributes_for :sources

  validates_presence_of :url, :name
  validate :validate_uri
  
  scope :popular, lambda { |limit| { :limit => limit, :order => "sites_count desc" }}
  scope :languages, :conditions => "buildables.category_id = categories.id AND categories.name='Programming Language'", :joins => { :buildables => :category }
  
  serialize :top_sites
  serialize :cached_categories
  serialize :cached_language

  before_save :update_cached_categories, :if => :categories_changed?
  before_save :update_url_from_uri
  
  composed_of :uri,
    :class_name => 'FriendlyUrl',
    :mapping    => %w(url to_s),
    :allow_nil  => true,
    :converter  => :new

  # def self.for_autocomplete(count = 20)
  #   Rails.cache.fetch "tool-for_autocomplete_#{count}" do
  #     popular(20).collect { |t| {"id" => t.id.to_s, "name" => "#{t.name} (#{t.sites_count})"}}
  #   end
  # end

  def self.for_autocomplete(count = 20)
    popular(20).collect { |t| {"id" => t.id.to_s, "name" => "#{t.name} (#{t.sites_count})", "description" => "(#{t.combined_category_names.join(", ")})"}}
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
        url = FriendlyUrl.new(row[0])
        if site = Site.find_by_friendly_url(url)
          using = self.usings.find_by_site_id(site.id)
        else
          site = Site.create({ :uri => url })
        end
      
        description = row[1..row.length].join(", ")
        description.strip! if description
        self.usings.create( {:site => site, :description => description }) unless using
      end
    end
  end
  handle_asynchronously :add_sites!
  
  def update_top_sites!
    self.top_sites = { :generated => Time.now, :sites => [] }
    sites.limit(20).order("google_pagerank desc").each do |site|
      self.top_sites[:sites] << { :name => site.title, :param => site.to_param }
    end
    save!
  end

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
  
  def update_articles!
    self.cached_articles = []
    self.articles.each do |article|
      self.cached_articles << { :id => article.id, :title => article.title}
    end
    save
  end

  def books_count
    0
  end
  
  def load_by_url
    Timeout::timeout(5) do
      agent = Mechanize.new
      agent.redirection_limit = 1
      agent.redirect_ok = true
      agent.user_agent_alias = 'Mac Safari'
      page = agent.get(uri.to_s)
      self.uri = page.uri.to_s if self.url != page.uri.to_s
      
      # <meta name="description" content="Describes the meta description tag and provides tips for search engine optimization with meta description tags. Use the meta tag generator to create meta description tags for your site." />
      
      meta_description = page.search("meta[name='description']")
      self.description = meta_description.first["content"] if meta_description.length > 0
    end
  rescue
    # ok to timeout
  end
  
  def self.find_by_friendly_url(friendly_url)
    Tool.find(:first, :conditions => ['url IN (?)', friendly_url.variants.collect(&:to_s)])
  end
  

  private
  def categories_changed?
    true
  end

  def validate_uri
    if uri.blank?
      errors.add(:url, "cannot be blank")
    elsif uri.to_s !~ Util::URL_HTTP_OPTIONAL || !uri.valid?
      errors.add(:url, "is not a valid URL")
    else
      conditions = if new_record?
                     ['url IN (?)', uri.variants.collect(&:to_s)]
                   else
                     ['url IN (?) AND id != ?', uri.variants.collect(&:to_s), id]
                   end

      if self.class.exists?(conditions)
        errors.add(:url, "has already been added")
        return false
      end
    end
    true
  end
  
  def update_url_from_uri
    self.url = uri.to_s
  end
end