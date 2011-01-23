class Using < ActiveRecord::Base
  belongs_to :site, :counter_cache => 'tools_count'
  belongs_to :tool, :counter_cache => 'sites_count'
  
  scope :recent, lambda { |limit| { :limit => limit, :order => "created_at desc" }}
  
  scope :by_sites_count, joins(:tool).order(:sites_count).includes(:tool)
  scope :by_alexa_site, joins(:site).order(:alexa_global_rank).includes(:site)
end