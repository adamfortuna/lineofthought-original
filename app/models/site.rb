class Site < ActiveRecord::Base
  has_friendly_id :domain_name, :use_slug => true
  validates_presence_of :title, :excerpt
  validates_length_of :excerpt, :maximum => 140
  
  has_many :usings
  has_many :tools, :through => :usings

  scope :popular, lambda { |limit| { :limit => limit, :order => "alexa_global_rank" }}
  
  def domain
    url.downcase.scan(/^.*?([^\.\/]+\.[a-z\.]{2,6})(:\d{1,5})?(\/.*)?$/i).join.gsub(/(:\d{1,5})?(\/.*)?/, '')
  end
  
  def domain_name
    domain.gsub(".com", "").gsub(".org", "").gsub(".net", "")
  end

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
  
  def snap_screenshot!
    wt = Webthumb.new('962a3d86dac6ab380ae08e2536bb1cb6')
    job = wt.thumbnail(:url => self.url)
    job.write_file(job.fetch(:medium2), '/tmp/medium2.jpg')
    job.write_file(job.fetch(:small), '/tmp/small.jpg')
  end
  handle_asynchronously :snap_screenshot!
  after_create :snap_screenshot!
  
end