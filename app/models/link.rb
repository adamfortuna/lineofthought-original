class Link < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  
  validates_presence_of :url, :uid, :canonical
  validates_uniqueness_of :url, :canonical

  serialize :cached_keywords
  serialize :cached_links
  serialize :lookup_urls

  has_one :source, :dependent => :destroy
  has_one :bookmark
  has_one :site
  has_one :tool
  belongs_to :page, :dependent => :destroy

  composed_of :uri,
    :class_name => 'HandyUrl',
    :mapping    => %w(url to_s),
    :allow_nil  => true,
    :converter  => :new  
  composed_of :original_uri,
    :class_name => 'HandyUrl',
    :mapping    => %w(original_url to_s),
    :allow_nil  => true,
    :converter  => :new  
  
  searchable do
    text :title, :default_boost => 2
    text :description
    text :url do
      lookup_urls
    end
    
    text :canonical do
      lookup_urls.collect do |url|
        HandyUrl.new(url).variants.collect(&:canonical)
      end.flatten.compact.uniq if lookup_urls
    end
    boolean :has_tool, :using => :has_tool?
    boolean :has_site, :using => :has_site?
    boolean :has_bookmark, :using => :has_bookmark?
  end
  handle_asynchronously :solr_index
    
  state_machine :status, :initial => :new do
    state :new do
    end

    state :loaded do
    end

    state :unreachable do
    end

    state :parsed do
    end
    
    state :unparseable do
    end

    before_transition :on => :load, :do => :load_html!
    event :load do
      transition [:new, :parsed, :unreachable] => :loaded, :if => :content_loaded?
      transition :new => :unreachable
    end
    
    before_transition :loaded => :parsed, :do => :parse_html!
    after_transition :to => :parsed, :do => :update_related_description
    event :parse do
      transition :loaded => :parsed, :if => :content_parsed?
      transition :loaded => :unparseable
    end
  end
  
  def parse_html!
    self.html_title      = current_page.html_title
    self.title           = current_page.title
    self.description     = current_page.description
    self.lede            = current_page.lede
    self.cached_keywords = current_page.keywords
    self.author          = current_page.author
    self.feed            = current_page.feed
    self.date_posted     = current_page.datetime
    self.cached_links    = current_page.links
    self.url             = current_page.url
    Favicon.create_by_favicon_url(current_page.favicon, uri) if current_page.favicon
    return true
  end  
  
  def current_page(reload = false)
    return page if page && page.loaded?
    new_page = Page.create({:url => url })
    self.update_attribute(:page_id, new_page.id)
    new_page
  end
  memoize :current_page
  
  def load_html!
    current_page
  end

  def content_loaded?
    current_page && current_page.success?
  end
  
  def content_parsed?
    current_page && current_page.parsed?
  end

  def self.find_or_create_by_domain(url)
    h = HandyUrl.new(url).root_url_with_subdomain
    find_or_create_by_url(h.to_s)
  rescue
    nil
  end
  
  def self.find_or_create_by_url(url)
    h = HandyUrl.new(Util.parse_uri(url))
    link, method = Link.find_by_entered_url(h)
    return link if link
    link = Link.create({:url => h.to_s})
    
    # If we weren't able to create this bookmark, the solr index 
    # might be out of date. Fallback on SQL.
    if link.new_record? && method == :solr
      link = Link.find_by_entered_url_using_sql(h)
    end
    return link
  rescue
    nil
  end
  
  def self.find_by_entered_url(url)
    url = HandyUrl.new(Util.parse_uri(url)) unless url.is_a?(HandyUrl)
    begin
      return Link.find_by_entered_url_using_solr(url), :solr
    rescue Errno::ECONNREFUSED
      # puts "Link.find_by_entered_url - loaded from sql"
      return Link.find_by_entered_url_using_sql(url), :sql
    end
  rescue
    nil
  end
  
  def self.find_by_entered_url_using_solr(url)
    search_results = Link.search do
      fulltext url.canonical
    end
    # puts "Link.find_by_entered_url - loaded from solr"
    search_results.results.first
  end

  def self.find_by_entered_url_using_sql(url)
    find(:first, :conditions => ["canonical = ? OR url IN (?) OR original_url IN (?)", 
                                  url.canonical,
                                  url.variants.collect(&:to_s),
                                  url.variants.collect(&:to_s)])
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
    tool_keywords = (cached_keywords || []).collect do |keyword|
      keyword[0] if known_tool_keywords.include?(keyword[0])
    end.compact
    
    url_variants = (cached_links || []).collect do |url|
      HandyUrl.new(url).variants.collect(&:to_s)
    end.flatten
    
    return [] if tool_keywords.blank? && url_variants.blank?
    Tool.joins(:link).where(["tools.keyword IN (?) OR links.url IN (?) OR links.original_url IN (?)", tool_keywords, url_variants, url_variants])
  end
  memoize :tools
  
  def sites
    uids = cached_links.collect do |url|
      HandyUrl.new(url).uid
    end
    return [] if uids.empty?
    Site.where(["uid IN (?)", uids])
  end

  def has_tool?
    !tool.nil?
  end

  def has_site?
    !site.nil?
  end

  def has_bookmark?
    !bookmark.nil?
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
    self.lookup_urls = [self.uri.to_s, self.original_uri.to_s].uniq.compact
    self.canonical = self.uri.canonical
    self.uid_with_subdomain = self.uri.uid_with_subdomain
    self.uid = self.uri.uid
  end
  
  def update_related_description
    return unless (self.description || self.lede)
    if site && site.description.blank?
      site.update_attribute(:description, self.description || self.lede)
    end
    if tool && tool.description.blank?
      tool.update_attribute(:description, self.description || self.lede)
    end
  end
  
  def initial_load!
    load! unless loaded?
    parse! if loaded?
  end
  after_create :initial_load!
  handle_asynchronously :initial_load!, :priority => -20
end