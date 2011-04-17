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
    load_url if !html_loaded?
    if !self.html.blank?
      @doc ||= Pismo::Document.new(self.html)
    end
  end
  
  def html_title
    doc.html_title
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
    t = Time.parse(doc.datetime)
    (t < 100.years.ago) ? nil : t
  rescue
    nil
  end
  
  def html_body
    doc.html_body
  end

  def links
    Nokogiri::XML::Document.parse(html_body).css("a").collect do |link|
      link["href"] if !Util.relative_url?(link["href"])
    end.compact
  rescue
    []
  end
  
  def favicon
    doc.favicon
  rescue
    nil
  end
  
  def html_loaded?
    self.success? && !self.html.blank?
  end
  
  def parsed?
    doc.title
    true
  rescue
    false
  end

  protected
  after_create :load_url
  def load_url
    Timeout::timeout(20) do
      agent = Mechanize.new
      agent.redirection_limit     = 5             # only follow 3 redirect
      agent.redirect_ok           = true          # follow redirects
      agent.user_agent_alias      = 'Mac Safari'  # cloak it
      page = agent.get(self.uri)
      self.url = page.uri.to_s if self.url != page.uri.to_s
      if page.is_a?(Mechanize::Page)
        self.html = page.send(:html_body)
      else
        self.html = page.body
      end
      if self.html
        self.html = self.html.gsub("\t","").gsub("\n","").gsub("\r","")
        self.html = Iconv.conv("UTF-8//IGNORE", "US-ASCII", self.html)
      end
      self.code = page.code
      self.success = true
    end
    save!
  rescue Mechanize::ResponseCodeError => e
    self.update_attributes({ :success => false, :code => e.message.to_i})
  rescue
    Timeout::timeout(10) do
      response = open(self.url)
      self.html = response.read
      self.code = response.status.first.to_i
      self.success = true if self.code == 200
      save!
    end
  end
end