class Category < ActiveRecord::Base
  has_many :buildables
  has_many :tools, :through => :buildables

  has_friendly_id :name, :use_slug => true
  validates_presence_of :name
end