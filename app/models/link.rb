class Link < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  attr_accessor :skip_load

  validates_presence_of :url, :uid, :canonical
  validates_uniqueness_of :url, :canonical

  serialize :cached_keywords
  serialize :cached_links

  has_one :source, :dependent => :destroy


  composed_of :uri,
    :class_name => 'HandyUrl',
    :mapping    => %w(url to_s),
    :allow_nil  => true,
    :converter  => :new  
  
  after_create :load_by_url, :unless => :skip_load?
  def load_by_url
    Timeout::timeout(20) do
      agent = Mechanize.new
      agent.redirection_limit     = 3             # only follow 3 redirect
      agent.redirect_ok           = true          # follow redirects
      agent.user_agent_alias      = 'Mac Safari'  # cloak it
      page = agent.get(original_url)
      self.url = page.uri.to_s if self.destination_url != page.uri.to_s
      self.html = page.send(:html_body)
    end
    parse_html!
  rescue
    update_attribute(:parsed, true)
  end
  handle_asynchronously :load_by_url
  
  def doc
    @doc ||= Pismo::Document.new(self.html)
  end
  
  def parse_html!
    self.title           = doc.title
    self.html_body       = doc.html_body
    self.body            = doc.body
    self.description     = doc.lede
    self.cached_keywords = doc.keywords
    self.author          = doc.author
    self.feed            = doc.feed
    self.date_posted     = doc.datetime
    self.cached_links    = Nokogiri::XML::Document.parse(doc.html_body).css("a").collect do |link|
      link["href"] if !Util.relative_url?(link["href"])
    end.compact
    Favicon.create_by_favion_url(doc.favicon, uri)
    self.parsed          = true
    save!
  rescue
    self.parsed = true
    save
  end
  
  def self.find_or_create_by_url(url, skip_load = false)
    handy_url = FriendlyUrl.new(url)
    link = Link.where(["canonical = ? OR original_url = ?", handy_url.canonical, url])
    if link.empty?
      Link.create({:url => url, :skip_load => skip_load})
    else
      link.first
    end
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

  before_validation :set_urls, :if => :url_changed?
  def set_urls
    self.original_url ||= self.url
    self.url = Util.normalize_url(self.url).to_s
    self.canonical = self.uri.canonical
    self.uid = self.uri.uid
  end
  
  def skip_load?
    skip_load
  end
end