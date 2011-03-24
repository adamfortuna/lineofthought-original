# Wrapper for parsing a page using pismo
class Page < ActiveRecord::Base
  has_one :link
  validates_presence_of :url

  composed_of :uri,
    :class_name => 'HandyUrl',
    :mapping    => %w(url to_s),
    :allow_nil  => true,
    :converter  => :new  
  
  def doc
    @doc ||= Pismo::Document.new(self.html)
  end

  def title
    doc.title
  end
  
  def description
    doc.description || doc.lede
  end

  def lede
    doc.lede
  end
  
  def keywords
    doc.keywords
  end

  def author
    doc.author
  end
  
  def feed
    doc.feed
  end
  
  def datetime
    doc.datetime
  end
  
  def html_body
    doc.html_body
  end

  def links
    Nokogiri::XML::Document.parse(html_body).css("a").collect do |link|
      link["href"] if !Util.relative_url?(link["href"])
    end.compact
  end
  
  def favicon
    doc.favicon
  end
  
  def loaded?
    success?
  end
  
  def parsed?
    doc.title
    true
  rescue
    false
  end

  private
  after_create :load_url
  def load_url
    Timeout::timeout(20) do
      agent = Mechanize.new
      agent.redirection_limit     = 3             # only follow 3 redirect
      agent.redirect_ok           = true          # follow redirects
      agent.user_agent_alias      = 'Mac Safari'  # cloak it
      page = agent.get(self.uri)
      self.url = page.uri.to_s if self.url != page.uri.to_s
      self.html = page.send(:html_body)
      self.code = page.code
      self.success = true
    end
    save!
  rescue Mechanize::ResponseCodeError => e
    self.update_attribute(:success, false)
  end
end