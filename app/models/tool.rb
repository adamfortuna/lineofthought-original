class Tool < ActiveRecord::Base
  validates_presence_of :name, :excerpt
  validates_length_of :excerpt, :maximum => 140
    
  belongs_to :category, :counter_cache => true
  belongs_to :language, :class_name => 'Tool'
  
  has_friendly_id :name, :use_slug => true
  
  has_many :buildables
  has_many :categories, :through => :buildables
  accepts_nested_attributes_for :categories

  has_many :usings
  has_many :sites, :through => :usings

  has_many :sources, :as => :sourceable  
  accepts_nested_attributes_for :sources
  
  scope :popular, lambda { |limit| { :limit => limit, :order => "sites_count desc" }}
  scope :languages, :conditions => "buildables.category_id = categories.id AND categories.name='Programming Language'", :joins => { :buildables => :category }

  has_attached_file :logo, :styles => { :medium => "300x300>", :thumb => "64x64>" }
  
  def self.for_autocomplete(count = 20)
    Rails.cache.fetch "tool-for_autocomplete_#{count}" do
      popular(20).collect { |t| {"id" => t.id.to_s, "name" => "#{t.name} (#{t.sites_count})"}}.to_json
    end
  end
  
  def jobs_count
    4
  end
  
  def articles_count
    6
  end
end