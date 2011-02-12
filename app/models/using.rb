class Using < ActiveRecord::Base
  belongs_to :site, :counter_cache => 'tools_count'
  belongs_to :tool, :counter_cache => 'sites_count'
  
  validates_uniqueness_of :tool_id, :scope => :site_id
  
  scope :recent, lambda { |limit| { :limit => limit, :order => "created_at desc" }}
  
  scope :by_alexa_site, joins(:site).order(:alexa_global_rank).includes(:site)
end