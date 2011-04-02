class Using < ActiveRecord::Base
  attr_accessor :tool_name, :tool_url # For implicit tool creation when a tool doesn't exist
  belongs_to :site, :counter_cache => 'tools_count'
  belongs_to :tool, :counter_cache => 'sites_count'

  attr_accessible :site_id, :tool_id, :tool_name, :tool_url, :user_id, :description

  has_many :bookmark_connections
  has_many :bookmarks, :through => :bookmark_connections
  
  validates_presence_of :site_id
  validates_presence_of :tool_id
  validates_uniqueness_of :tool_id, :scope => :site_id, :message => "has already been added to this site."
  
  scope :recent, :order => "created_at desc"
  scope :by_alexa_site, joins(:site).order(:alexa_global_rank).includes(:site)
  
  after_create :update_caches
  after_destroy :update_caches
  
  serialize :cached_bookmarks
  
  def update_cached_bookmarks!
    self.cached_bookmarks = []
    self.cached_bookmarks = bookmarks.order("created_at desc").limit(5).collect do |bookmark|
      { :title => bookmark.title, 
        :description => bookmark.description, 
        :param => bookmark.cached_slug,
        :id => bookmark.id }
    end
    save
  end

  private
  def update_caches
    site.update_cached_tools_in_background!
    tool.update_cached_sites_in_background!
  end
  
  before_validation :create_new_tool, :if => :creating_with_new_tool?, :on => :create
  def creating_with_new_tool?
    tool_id.nil? && (tool_name || tool_url)
  end
  def create_new_tool
    return true if tool_name.blank? && tool_url.blank?
    
    # If they gave a URL for this tool, try to look it up by that
    if !tool_url.blank? && tool_url =~ Util::URL_HTTP_OPTIONAL
      self.tool = Tool.find_by_url(tool_url)
    elsif !tool_name.blank?
      # Make sure this tool hasn't been added to this site before
      self.tool = self.site.tools.find(:first, :conditions => ["name = ?", tool_name])
    end
    if self.tool.nil?
      self.tool = Tool.new({ :name => tool_name, :url => tool_url.blank? ? nil : tool_url})
      self.tool.save
    end

    self.errors.add_to_base(self.tool.errors.full_messages.join(", ")) unless self.tool.valid?
    return true
  end
end