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
  validates_uniqueness_of :url
  
  scope :popular, lambda { |limit| { :limit => limit, :order => "sites_count desc" }}
  scope :languages, :conditions => "buildables.category_id = categories.id AND categories.name='Programming Language'", :joins => { :buildables => :category }
  
  serialize :top_sites
  serialize :cached_categories
  serialize :cached_language

  before_save :update_cached_categories, :if => :categories_changed?
  
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

  def jobs_count
    4
  end
  
  def books_count
    3
  end
  
  private
  def categories_changed?
    true
  end
end