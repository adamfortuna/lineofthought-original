class Category < ActiveRecord::Base
  has_many :tools

  has_friendly_id :name, :use_slug => true
  validates_presence_of :name
end