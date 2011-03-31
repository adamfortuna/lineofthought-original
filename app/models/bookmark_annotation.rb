class BookmarkAnnotation < ActiveRecord::Base
  belongs_to :annotateable, :polymorphic => true, :counter_cache => 'bookmarks_count'
  belongs_to :site, :class_name => "Site", :foreign_key => "annotateable_id"
  belongs_to :tool, :class_name => "Tool", :foreign_key => "annotateable_id"
  belongs_to :bookmark
  belongs_to :bookmark_user, :primary_key => "user_bookmark_id", :class_name => 'Bookmark'

  validates_uniqueness_of :bookmark_id, :scope => [:annotateable_id, :annotateable_type, :user_bookmark_id]
  validates_uniqueness_of :user_bookmark_id, :scope => [:annotateable_id, :annotateable_type, :bookmark_id]
  after_create :update_caches!
  after_destroy :update_caches!

  private
  def update_caches!
    annotateable.update_bookmarks!
  end
  handle_asynchronously :update_caches!
end