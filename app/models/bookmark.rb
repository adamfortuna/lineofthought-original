class Bookmark < ActiveRecord::Base
  has_friendly_id :title, :use_slug => true
  include HasFavicon

  validates_presence_of :title, :url
  
  has_many :annotations
  has_many :bookmark_connections
  has_many :usings, :through => :bookmark_connections
  belongs_to :link

  serialize :cached_tools
  serialize :cached_sites
  serialize :cached_connections
  
  scope :recent, lambda { |n=5| order("created_at desc").limit(n) }

  attr_accessor :tools, :sites, :usings

  def self.new_from_link(link)
    Bookmark.new({ :url => link.url,
                   :link => link, 
                   :title => link.title,
                   :description => link.description,
                   :tools => link.tools,
                   :sites => link.sites })
  end

  after_save :create_usings, :if => :has_usings?
  def create_usings
    self.usings.each do |using|
      found_using = Using.find(:first, :conditions => ["tool_id = ? AND site_id = ?", using["tool_id"], using["site_id"]])
      found_using = Using.create({ :tool_id => using["tool_id"], :site_id => using["site_id"] }) if !found_using
      self.bookmark_connections.create({:using => found_using})
    end
  end

  def has_usings?
    !self.usings.nil?
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
  # 
  # def tools=(tools)
  #   self.tool_ids = tools.collect(&:id)
  # end
  # 
  def tool_ids=(ids)
    transaction do
      if new_record?
        self.annotations = []
        self.cached_tools = []
      else
        annotations.where(["annotateable_type=? AND annotateable_id NOT IN (?)", 'Tool', ids]).each do |annotation|
          annotation.destroy
        end
      end
      Tool.where(["id IN (?)", ids]).each  do |tool|
        self.annotations.build({:annotateable => tool}) unless has_tool?(tool.id)
      end
    end
  end

  def tools_count
    cached_tools ? cached_tools.count : 0
  end

  def site_ids
    annotations.where(["annotateable_type=?", 'Site']).select(:annotateable_id).collect(&:annotateable_id)
  end
  
  def sites_for_display
    sites.collect do |site|
      { :name => "#{site.title} (#{site.url})", :id => site.id.to_s }
    end
  end
  
  
  def site_ids=(ids)
    transaction do
      annotations.where(["annotateable_type=? AND annotateable_id NOT IN (?)", 'Site', ids]).each do |annotation|
        annotation.destroy
      end
      Site.where(["id IN (?)", ids]).each  do |site|
        self.annotations.build({:annotateable => site}) unless has_site?(site.id)
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
  
  def update_caches
    self.cached_tools = []
    self.cached_sites = []
    self.cached_connections = []
    annotations.includes(:annotateable).each do |annotation|
      if annotation.annotateable_type == "Tool"
        self.cached_tools << { :id => annotation.annotateable.id, :name => annotation.annotateable.name, :param => annotation.annotateable.cached_slug }
      else
        self.cached_sites << { :id => annotation.annotateable.id, :name => annotation.annotateable.title, :param => annotation.annotateable.cached_slug }
      end
    end
  end
  
  def update_caches!
    update_caches
    save
  end
end