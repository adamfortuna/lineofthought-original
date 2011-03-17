class Using < ActiveRecord::Base
  belongs_to :site, :counter_cache => 'tools_count'
  belongs_to :tool, :counter_cache => 'sites_count'
  
  validates_uniqueness_of :tool_id, :scope => :site_id
  
  scope :recent, lambda { |limit| { :limit => limit, :order => "created_at desc" }}
  scope :by_alexa_site, joins(:site).order(:alexa_global_rank).includes(:site)
  
  after_create :update_caches
  after_destroy :update_caches
  
  private
  def update_caches
    site.update_cached_tools_in_background!
    tool.update_cached_sites_in_background!
  end
end