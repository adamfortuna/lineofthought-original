class Bookmark < ActiveRecord::Base
  has_friendly_id :title, :use_slug => true
  include HasFavicon

  validates_presence_of :title, :url
  
  has_many :bookmark_annotations, :dependent => :destroy
  has_many :bookmark_connections, :dependent => :destroy
  has_many :bookmark_users, :foreign_key => :parent_id, :dependent => :destroy
  has_many :usings, :through => :bookmark_connections
  has_many :sites, :through => :bookmark_annotations, :source => :site,
                   :conditions => "bookmark_annotations.annotateable_type = 'Site'"
  has_many :tools, :through => :bookmark_annotations, :source => :tool,
                   :conditions => "bookmark_annotations.annotateable_type = 'Tool'"
  belongs_to :link

  serialize :cached_tools
  serialize :cached_sites
  serialize :cached_connections
  
  scope :recent, order("created_at desc")
  scope :without_user, where("parent_id is NULL")

  before_destroy :update_remote_caches!

  composed_of :uri,
    :class_name => 'HandyUrl',
    :mapping    => %w(url to_s),
    :allow_nil  => true,
    :converter  => :new

  attr_accessor :using_params

  searchable do
    text :title, :default_boost => 2
    string :url
    string :type
    text :description
    time :created_at
    
    text :tools do
      cached_tools.map { |tool| tool[:name] } if cached_tools
    end
    text :sites do
      cached_sites.map { |site| site[:name] } if cached_sites
    end
  end
  handle_asynchronously :solr_index
  
  def self.new_from_link(link)
    Bookmark.new({ :url => link.url,
                   :link => link, 
                   :title => link.title,
                   :description => link.description,
                   :tools => link.tools,
                   :sites => link.sites,
                   :has_favicon => link.has_favicon })
  end
  
  def self.create_from_link(link)
    bookmark = new_from_link(link)
    bookmark.save
    bookmark
  end
  
  def to_user
    BookmarkUser.new({ :url => url,
                   :link => link, 
                   :title => title,
                   :description => description,
                   :is_video => is_video,
                   :is_presentation => is_presentation,
                   :has_favicon => has_favicon,
                   :cached_tools => cached_tools,
                   :cached_sites => cached_sites,
                   :cached_connections => cached_connections
    })
  end


  # Updates the various values of this bookmark based on what people have tagged it with
  def reindex    
    user_bookmark = bookmark_users.first
    self.title = user_bookmark.title
    self.description = user_bookmark.description
    
    # Update tools
    self.tool_ids = BookmarkAnnotation.where(["bookmark_id = ? AND user_bookmark_id IS NOT NULL AND annotateable_type='Tool'", self.id]).select("annotateable_id, count(1) count").group([:bookmark_id, :annotateable_id]).collect(&:annotateable_id)  
    # Update sites  
    self.site_ids = BookmarkAnnotation.where(["bookmark_id = ? AND user_bookmark_id IS NOT NULL AND annotateable_type='Site'", self.id]).select("annotateable_id, count(1) count").group([:bookmark_id, :annotateable_id]).collect(&:annotateable_id)
    
    self.cached_connections = []
  end
  
  def reindex!
    reindex
    save
  end

  def self.search_by_params(params, class_name = 'Bookmark')
    search = search do
      with(:type, class_name)
      keywords params[:search] if params[:search]
      order_by(:created_at, :desc)
      paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 20)
    end
    puts "Loaded bookmarks using solr"
    return search.results, search.hits, true
  rescue Errno::ECONNREFUSED
    puts "Unable to Connect to Solr to retreive bookmarks. Falling back on SQL."
    bookmarks = Bookmark.order("created_at desc")
                 .paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 20)
    return bookmarks, bookmarks, false
  end

















  after_save :create_usings, :if => :has_new_usings?
  def create_usings
    new_using_ids = self.using_params.collect { |u| u["using_id"].to_i }.compact
    self.bookmark_connections.each do |connection|
      connection.destroy if new_using_ids.include?(connection.using_id)
    end
    self.using_params.each do |using|
      if using["tool_id"] && using["site_id"]
        new_using = Using.find(:first, :conditions => ["tool_id = ? AND site_id = ?", using["tool_id"], using["site_id"]])
        new_using = Using.create({ :tool_id => using["tool_id"], :site_id => using["site_id"] }) if !new_using
        self.bookmark_connections.create({:using => new_using})
      end
    end
  end

  def has_new_usings?
    !self.using_params.nil?
  end





  def tools_for_display
    tools.collect do |tool|
      { :name => "#{tool.name}#{" (#{tool.cached_language.name})" if tool.cached_language}", :id => tool.id.to_s }
    end
  end

  def tool_ids=(ids)
    transaction do
      self.cached_tools = []
      if !new_record?
        bookmark_annotations.where(["annotateable_type=? AND annotateable_id NOT IN (?)", 'Tool', ids]).each do |annotation|
          annotation.destroy
        end
      end
      Tool.where(["id IN (?)", ids]).each  do |tool|
        if new_record? || !bookmark_annotations.exists?(["annotateable_type=? AND annotateable_id = ?", 'Tool', tool.id])
          self.bookmark_annotations.build({:annotateable => tool})
        end
        self.cached_tools << { :id => tool.id, :name => tool.name, :param => tool.cached_slug }
      end
    end
  end

  def tools_count
    cached_tools ? cached_tools.count : 0
  end

  def has_tool?(id)
    cached_tools ? (cached_tools.count { |tool| tool[:id] == id } > 0) : false
  end

  def cached_tool_ids
    cached_tools.collect { |t| t[:id] }
  end


  
  def sites_for_display
    sites.collect do |site|
      { :name => "#{site.title} (#{site.url})", :id => site.id.to_s }
    end
  end

  def site_ids=(ids)
    transaction do
      self.cached_sites = []
      if !new_record?
        bookmark_annotations.where(["annotateable_type=? AND annotateable_id NOT IN (?)", 'Site', ids]).each do |annotation|
          annotation.destroy
        end
      end
      Site.where(["id IN (?)", ids]).each  do |site|
        if !bookmark_annotations.exists?(["annotateable_type=? AND annotateable_id = ?", 'Site', site.id])
          self.bookmark_annotations.build({:annotateable => site}) unless has_site?(site.id)
        end
        self.cached_sites << { :id => site.id, :name => site.title, :param => site.cached_slug }
      end
    end
  end

  def cached_site_ids
    cached_sites.collect { |s| s[:id] }
  end

  def sites_count
    cached_sites ? cached_sites.count : 0
  end

  def has_site?(id)
    cached_sites ? (cached_sites.count { |site| site[:id] == id } > 0) : false
  end

  
  def update_remote_caches!
    sites.collect(&:update_bookmarks!)
    tools.collect(&:update_bookmarks!)
  end
  

  
  private
  before_save :update_uid, :if => :url_changed?
  def update_uid
    self.uid = uri.uid if uri
  end
end