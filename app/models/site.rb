class Site < ActiveRecord::Base
  has_friendly_id :domain_name, :use_slug => true

  validates_presence_of :title, :url
  validate :validate_uri
  
  has_many :usings
  has_many :tools, :through => :usings
  acts_as_recommendable :tools, :through => :usings, :use_dataset => true, :limit => 5

  scope :popular, lambda { |limit| { :limit => limit, :order => "alexa_global_rank" }}
  scope :with_tools, lambda { |count| { :conditions => ["tools_count > ?", count] } }

  before_validation :default_title_to_domain, :on => :create

  composed_of :uri,
    :class_name => 'FriendlyUrl',
    :mapping    => %w(url to_s),
    :allow_nil  => true,
    :converter  => :new

  delegate :host, :path, :port, :domain, :domain_name, :to => :uri
  serialize :top_tools

  # Todo: Make this the root of the current URL, rather than the domain
  def site_root
    "http://#{domain}"
  end
    
    
  def update_ranks!
    ranks = PageRankr.ranks(site_root, :alexa, :google) #=> {:alexa=>{:us=>1, :global=>1}, :google=>10}
    self.update_attributes({ :alexa_us_rank => ranks[:alexa][:us], 
                             :alexa_global_rank => ranks[:alexa][:global], 
                             :google_pagerank => ranks[:google]}) if ranks
  end
  handle_asynchronously :update_ranks!
  after_create :update_ranks!
  
  def update_top_tools!
    self.top_tools = { :generated => Time.now, :tools => [] }
    tools.where("sites_count > 0").limit(20).order("sites_count desc").each do |tool|
      self.top_tools[:tools] << { :name => tool.name, :param => tool.to_param }
    end
    save
  end
  
  def update_top_tools_in_background!
    update_top_tools!
  end
  handle_asynchronously :update_top_tools_in_background!
  
  def jobs_count
    4
  end
  
  def articles_count
    6
  end
  
  def self.find_by_friendly_url(friendly_url)
    Site.find(:first, :conditions => ['url IN (?)', friendly_url.variants.collect(&:to_s)])
  end
  
  def tools_hash
    self.tools.collect do |tool|
      { "id" => tool.id.to_s, "name" => "#{tool.name} (#{tool.sites_count})"}
    end
  end
  
  private
  ##
  # Custom validations for blog URI.  Validates that it's present, valid, and
  # hasn't already been taken.
  # 
  def validate_uri
    if uri.to_s !~ Util::URL_HTTP_OPTIONAL || !uri.valid? # valid?
      errors.add(:uri, "is not a valid URL")
    else # taken?
      # TODO: relax this constraint so that URL is only required to be unique
      # among the user's blogs.  If the blog is approved, then the URL must be
      # globally unique (ie. two people can't both have techcrunch.com as
      # approved blogs).
      conditions = if new_record?
                     ['url IN (?)', uri.variants.collect(&:to_s)]
                   else
                     ['url IN (?) AND id != ?', uri.variants.collect(&:to_s), id]
                   end
      errors.add(:uri, "is already in use") if self.class.exists?(conditions)
    end
  end
  
  def default_title_to_domain
    self.title = domain_name unless self.title
  end
end