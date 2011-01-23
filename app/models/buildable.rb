class Buildable < ActiveRecord::Base
  belongs_to :tool
  belongs_to :category, :counter_cache => 'tools_count'
end