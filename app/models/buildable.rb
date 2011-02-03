class Buildable < ActiveRecord::Base
  belongs_to :tool
  belongs_to :category, :counter_cache => 'tools_count'
  
  # after_create :update_cached_categories!
  # after_destroy :update_cached_categories!
  
  private
  def update_cached_categories!
    tool.update_cached_categories!
  end
end