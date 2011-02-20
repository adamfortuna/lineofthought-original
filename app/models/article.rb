class Article < ActiveRecord::Base
  has_friendly_id :title, :use_slug => true
  validates_presence_of :title, :url
  
  has_many :annotations

  serialize :cached_tools
  serialize :cached_sites
  serialize :cached_connections

  def tool_ids
    annotations.where(["annotateable_type=?", 'Tool']).select(:annotateable_id).collect(&:annotateable_id)
  end
  
  def tool_ids=(ids)
    transaction do
      annotations.where(["annotateable_type=? AND annotateable_id NOT IN (?)", 'Tool', ids]).each do |annotation|
        annotation.destroy
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

  def self.find_by_friendly_url(friendly_url)
    Article.find(:first, :conditions => ['url IN (?)', friendly_url.variants.collect(&:to_s)])
  end
  
  def has_tool?(id)
    cached_tools ? (cached_tools.count { |tool| tool[:id] == id } > 0) : false
  end

  def has_site?(id)
    cached_sites ? (cached_sites.count { |site| site[:id] == id } > 0) : false
  end
  
  before_save :update_caches!
  def update_caches!
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
end