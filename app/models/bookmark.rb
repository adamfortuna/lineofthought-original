class Bookmark < ActiveRecord::Base
  has_friendly_id :title, :use_slug => true
  include HasFavicon

  validates_presence_of :title, :url
  
  has_many :annotations, :dependent => :destroy
  has_many :bookmark_connections, :dependent => :destroy
  has_many :usings, :through => :bookmark_connections
  belongs_to :link

  serialize :cached_tools
  serialize :cached_sites
  serialize :cached_connections
  
  scope :recent, order("created_at desc")

  before_destroy :update_remote_caches!

  composed_of :uri,
    :class_name => 'HandyUrl',
    :mapping    => %w(url to_s),
    :allow_nil  => true,
    :converter  => :new

  attr_accessor :tools, :sites, :using_params

  def self.new_from_link(link)
    Bookmark.new({ :url => link.url,
                   :link => link, 
                   :title => link.title,
                   :description => link.description,
                   :tools => link.tools,
                   :sites => link.sites })
  end
  
  def self.create_from_link(link)
    bookmark = new_from_link(link)
    bookmark.save
    bookmark
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

  def tool_ids
    if new_record?
      annotations.collect(&:annotateable_id)
    else
      annotations.where(["annotateable_type=?", 'Tool']).select(:annotateable_id).collect(&:annotateable_id)
    end
  end
  
  def tools
    annotations.where(["annotateable_type=?", 'Tool']).includes(:annotateable).collect(&:annotateable)
  end
  # 
  # def tools=(tools)
  #   self.tool_ids = tools.collect(&:id)
  # end
  # 
  def tool_ids=(ids)
    transaction do
      self.cached_tools = []
      if !new_record?
        annotations.where(["annotateable_type=? AND annotateable_id NOT IN (?)", 'Tool', ids]).each do |annotation|
          annotation.destroy
        end
      end
      Tool.where(["id IN (?)", ids]).each  do |tool|
        if !annotations.exists?(["annotateable_type=? AND annotateable_id = ?", 'Tool', tool.id])
          self.annotations.build({:annotateable => tool})
        end
        self.cached_tools << { :id => tool.id, :name => tool.name, :param => tool.cached_slug }
      end
    end
  end

  def tools_count
    cached_tools ? cached_tools.count : 0
  end

  def site_ids
    annotations.where(["annotateable_type=?", 'Site']).collect(&:annotateable_id)
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
        annotations.where(["annotateable_type=? AND annotateable_id NOT IN (?)", 'Site', ids]).each do |annotation|
          annotation.destroy
        end
      end
      Site.where(["id IN (?)", ids]).each  do |site|
        if !annotations.exists?(["annotateable_type=? AND annotateable_id = ?", 'Site', site.id])
          self.annotations.build({:annotateable => site}) unless has_site?(site.id)
        end
        self.cached_sites << { :id => site.id, :name => site.title, :param => site.cached_slug }
      end
    end
  end

  def sites_count
    cached_sites ? cached_sites.count : 0
  end

  def self.find_by_handy_url(handy_url)
    find(:first, :conditions => ['url IN (?)', handy_url.variants.collect(&:to_s)])
  end
  
  def has_tool?(id)
    cached_tools ? (cached_tools.count { |tool| tool[:id] == id } > 0) : false
  end

  def has_site?(id)
    cached_sites ? (cached_sites.count { |site| site[:id] == id } > 0) : false
  end
  
  def sites
    annotations.where(["annotateable_type=?", 'Site']).collect(&:annotateable)
  end
  
  # def update_caches
  #   self.cached_tools = []
  #   self.cached_sites = []
  #   self.cached_connections = []
  #   annotations.includes(:annotateable).each do |annotation|
  #     if annotation.annotateable_type == "Tool"
  #       self.cached_tools << { :id => annotation.annotateable.id, :name => annotation.annotateable.name, :param => annotation.annotateable.cached_slug }
  #     else
  #       self.cached_sites << { :id => annotation.annotateable.id, :name => annotation.annotateable.title, :param => annotation.annotateable.cached_slug }
  #     end
  #   end
  # end
  # 
  # def update_caches!
  #   update_caches
  #   save
  # end
  
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