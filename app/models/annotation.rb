class Annotation < ActiveRecord::Base
  belongs_to :annotateable, :polymorphic => true, :counter_cache => 'bookmarks_count'
  belongs_to :bookmark

  validates_uniqueness_of :bookmark_id, :scope => [:annotateable_id, :annotateable_type]
  after_create :update_caches
  after_destroy :update_annotateable_cache!

  private
  def update_caches
    annotateable.update_bookmarks!
  end
  def update_annotateable_cache!
    annotateable.update_bookmarks!    
  end
end