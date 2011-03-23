class Link < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  attr_accessor :skip_load

  searchable do
    string :url # The actual URL visited
    string :original_url # The URL entered by the user
    string :uid # for favicons
    string :uid_with_subdomain
    string :canonical
  end
  handle_asynchronously :solr_index
  
  validates_presence_of :url, :uid, :canonical
  validates_uniqueness_of :url, :canonical

  serialize :cached_keywords
  serialize :cached_links

  has_one :source, :dependent => :destroy
  has_one :site
  has_one :tool
  belongs_to :page, :dependent => :destroy

  composed_of :uri,
    :class_name => 'HandyUrl',
    :mapping    => %w(url to_s),
    :allow_nil  => true,
    :converter  => :new  
  
  def parse_html
    self.title           = current_page.title
    self.description     = current_page.description
    self.lede            = current_page.lede
    self.cached_keywords = current_page.keywords
    self.author          = current_page.author
    self.feed            = current_page.feed
    self.date_posted     = current_page.datetime
    self.cached_links    = current_page.links
    Favicon.create_by_favicon_url(current_page.favicon, uri)
    self.parsed          = true
    save!
    update_related_description
  end
  handle_asynchronously :parse_html
  after_create :parse_html, :unless => :skip_load?
  
  
  def current_page(reload = false)
    return page if page && page.loaded?
    new_page = Page.create({:url => url })
    self.update_attribute(:page_id, new_page.id)
    new_page
  end
  memoize :current_page


  def self.find_or_create_by_domain(url, skip_load = false)
    h = HandyUrl.new(url).root_url_with_subdomain
    find_or_create_by_url(h.to_s, skip_load)
  end
  
  def self.find_or_create_by_url(url, skip_load = false)
    h = HandyUrl.new(url)
    link = Link.find(:first, :conditions => ["url IN (?) OR original_url IN (?)", h.variants, h.variants])
    return link if link
    return Link.create({:url => h.to_s, :skip_load => skip_load})
  end

  def categories
    return [] if cached_keywords.nil? || cached_keywords.empty?
    category_keywords = cached_keywords.collect do |keyword|
      keyword[0] if known_category_keywords.include?(keyword[0])
    end.compact
    return [] if category_keywords.blank?
    Category.where(["categories.keyword IN (?)", category_keywords])
  end
  memoize :categories

  def tools
    tool_keywords = cached_keywords.collect do |keyword|
      keyword[0] if known_tool_keywords.include?(keyword[0])
    end.compact
    return [] if tool_keywords.blank?
    Tool.where(["tools.keyword IN (?)", tool_keywords])
  end
  memoize :tools
  
  def sites
    uids = cached_links.collect do |url|
      HandyUrl.new(url).uid
    end
    return [] if uids.empty?
    Site.where(["uid IN (?)", uids])
  end

  private

  def known_category_keywords
    Rails.cache.fetch("known_category_keywords", :expires_in => 1.hour) do
      all_keywords = []
      Category.find_in_batches(:conditions => "keyword IS NOT NULL", :select => :keyword) do |category|
        category.each do |category|
          all_keywords << category.keyword
        end
      end
      all_keywords
    end
  end
  memoize :known_category_keywords

  def known_tool_keywords
    Rails.cache.fetch("known_tool_keywords", :expires_in => 1.hour) do
      all_keywords = []
      Tool.find_in_batches(:conditions => "keyword IS NOT NULL", :select => :keyword) do |tools|
        tools.each do |tool|
          all_keywords << tool.keyword
        end
      end
      all_keywords
    end
  end
  memoize :known_tool_keywords

  before_validation :set_urls, :if => :url_changed?
  def set_urls
    self.original_url ||= self.url
    self.url = Util.normalize_url(self.url).to_s
    self.canonical = self.uri.canonical
    self.uid_with_subdomain = self.uri.uid_with_subdomain
    self.uid = self.uri.uid
  end
  
  def skip_load?
    skip_load
  end
  
  def update_related_description
    if site && site.description.blank? && (self.description || self.lede)
      site.update_attribute(:description, self.description || self.lede)
    end
    if tool && tool.description.blank? && (self.description || self.lede)
      tool.update_attribute(:description, self.description || self.lede)
    end
  end
end