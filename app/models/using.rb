class Using < ActiveRecord::Base
  attr_accessor :tool_name, :tool_url,
                :site_title, :site_url # For implicit tool creation when a tool doesn't exist
  has_paper_trail :only => [:description, :user_id]
  acts_as_paranoid
  validates_as_paranoid
  belongs_to :site, :counter_cache => 'tools_count'
  belongs_to :tool, :counter_cache => 'sites_count'
  belongs_to :user, :counter_cache => 'lines_count'

  attr_accessible :site_id, :tool_id, :tool_name, :tool_url, :user_id, :description, :deleted_at, :site_title, :site_url

  has_many :bookmark_connections, :dependent => :destroy
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
  
  def restore!
    using = Using.with_deleted.find(:first, :conditions => ["site_id = ? AND tool_id = ?", self.site_id, self.tool_id])
    if using
      using.update_attributes({ :deleted => nil, :description => self.description, :user_id => self.user_id })
    else
      self.save!
    end
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

    if self.tool.new_record?
      self.errors.add_to_base(self.tool.errors.full_messages.join(", "))
    else
      self.tool_id = self.tool.id
    end
    return true
  end
  
  before_validation :create_new_site, :if => :creating_with_new_site?, :on => :create
  def creating_with_new_site?
    site_id.nil? && (site_title && site_url)
  end
  def create_new_site
    return true if site_title.blank? || site_url.blank?
    
    # If they have a URL for this tool, try to look it up by that
    if !site_url.blank? && site_url =~ Util::URL_HTTP_OPTIONAL
      self.site = Site.find_by_url(site_url)
    end

    if self.site.nil?
      self.site = Site.new({ :title => site_title, :url => site_url })
      self.site.save
    end
    
    if self.site.new_record?
      self.errors.add_to_base(self.site.errors.full_messages.join(", "))
    else
      self.site_id = self.site.id
    end    
    return true
  end
  
  before_validation :verify_permissions, :on => :create
  def verify_permissions
    return true if !self.errors.empty? || self.user.nil?
    # Verify the current user can add tools to this site.
    if self.site_id && !self.user.can_add_lines?(self.site)
      self.errors.add_to_base("The site you entered has been locked. You cannot add new tools to it at this time.")
    end
  end
end