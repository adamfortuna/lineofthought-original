require 'csv'
class Tool < ActiveRecord::Base

  attr_accessor :csv
  has_friendly_id :name, :use_slug => true
  
  belongs_to :language, :class_name => 'Tool'
  has_many :buildables
  has_many :categories, :through => :buildables
  has_many :usings
  has_many :sites, :through => :usings
  has_many :sources, :as => :sourceable  

  accepts_nested_attributes_for :categories
  accepts_nested_attributes_for :sources

  validates_presence_of :url, :name
  validates_uniqueness_of :url
  
  scope :popular, lambda { |limit| { :limit => limit, :order => "sites_count desc" }}
  scope :languages, :conditions => "buildables.category_id = categories.id AND categories.name='Programming Language'", :joins => { :buildables => :category }
  
  attr_accessible :name, :url, :description
  serialize :top_sites
  serialize :cached_categories
  serialize :cached_language
  
  def self.for_autocomplete(count = 20)
    Rails.cache.fetch "tool-for_autocomplete_#{count}" do
      popular(20).collect { |t| {"id" => t.id.to_s, "name" => "#{t.name} (#{t.sites_count})"}}.to_json
    end
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

  def update_cached_categories!
    self.cached_categories = []
    self.categories.order(:name).each do |category|
      self.cached_categories << { :name => category.name, :param => category.to_param }
    end
    self.cached_language = nil
    self.cached_language = { :name => language.name, :param => language.to_param } if language
      
    save!
  end

  def jobs_count
    4
  end
  
  def articles_count
    6
  end
end