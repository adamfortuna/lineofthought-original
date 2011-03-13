class Link < ActiveRecord::Base
  validates_presence_of :original_url, :normalized_url, :uid
  validates_uniqueness_of :normalized_url
  serialize :cached_keywords
  serialize :cached_links

  composed_of :uri,
    :class_name => 'FriendlyUrl',
    :mapping    => %w(destination_url to_s),
    :allow_nil  => true,
    :converter  => :new  
  
  after_create :load_by_original_url
  def load_by_original_url
    Timeout::timeout(20) do
      agent = Mechanize.new
      agent.redirection_limit     = 3             # only follow 3 redirect
      agent.redirect_ok           = true          # follow redirects
      agent.user_agent_alias      = 'Mac Safari'  # cloak it
      page = agent.get(original_url.downcase)
      self.destination_url = page.uri.to_s if self.destination_url != page.uri.to_s
      self.html = page.send(:html_body)
    end
    parse_html!
  end
  handle_asynchronously :load_by_original_url
  
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
    save
  end

  private
  before_validation :set_urls, :on => :create
  def set_urls
    self.original_url = Util.normalize_url(self.original_url)
    self.normalized_url = Util.parse_uri(self.original_url).to_s
    self.destination_url = self.original_url
    self.uid = self.uri.uid
  end
end