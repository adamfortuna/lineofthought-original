class Tool < ActiveRecord::Base
  belongs_to :category, :counter_cache => true

  has_friendly_id :name, :use_slug => true
  validates_presence_of :name, :excerpt
  validates_length_of :excerpt, :maximum => 140
    
  has_many :usings
  has_many :sites, :through => :usings

  has_many :sources, :as => :sourceable  
  accepts_nested_attributes_for :sources
  
  scope :popular, lambda { |limit| { :limit => limit, :order => "sites_count desc" }}
  
  def self.for_autocomplete(count = 20)
    Rails.cache.fetch "tool-for_autocomplete_#{count}" do
      popular(20).collect { |t| {"id" => t.id.to_s, "name" => "#{t.name} (#{t.sites_count})"}}.to_json
    end
  end
end