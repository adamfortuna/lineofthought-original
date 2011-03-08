require 'csv'
class Tool < ActiveRecord::Base
  has_attached_file :favicon,
                    :styles => { 
                      :small => { :geometry => "16x16>", :format => 'png' },
                      :large => { :geometry => "48x48>", :format => 'png' }
                    },
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root}/config/s3.yml",
                    :path => "/images/tools/:uid.:style.:extension"
  attr_protected :favicon_file_name, :favicon_content_type, :favicon_size
  has_friendly_id :name, :use_slug => true

  attr_accessible :name, :url, :description, :category_ids, :language_id, :favicon_url
  attr_accessor :csv
  
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
  delegate :host, :path, :port, :domain, :full_uid, :uid, :to => :uri

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
  
  def loader
    @loader ||= Loader.new(url)
  end
  
  def load_by_url
    self.name ||= loader.title
    self.description ||= loader.description
    self.favicon_url = (loader.favicon || "#{uri.scheme}://#{host}/favicon.ico") if self.favicon_url.blank?
    self.language ||= loader.tools.languages.first rescue nil
    self.categories = loader.categories if self.categories.blank?
  end
  
  def self.find_by_friendly_url(friendly_url)
    Tool.find(:first, :conditions => ['url IN (?)', friendly_url.variants.collect(&:to_s)])
  end

  def download_favicon!
    self.favicon = download_remote_image
    save
  end
  handle_asynchronously :download_favicon!
  after_save :download_favicon!, :if => :favicon_url_changed?

  def has_favicon?
    !favicon_file_name.blank?
  end

  def full_favicon_url(style = "small")
    "http://s3.amazonaws.com/s.lineofthought.com/images/tools/#{uid}.#{style}.png"
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
  
  def favicon_url_provided?
    !self.favicon_url.blank?
  end

  def download_remote_image
    io = open(URI.parse(favicon_url))
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
  end
end