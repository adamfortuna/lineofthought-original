class BookmarkUser < ActiveRecord::Base
  belongs_to :bookmark
  belongs_to :user_id, :counter_cache => 'bookmarks_count'
  after_create :update_cached_using!
  after_destroy :update_cached_using!
  
  validates_uniqueness_of :using_id, :scope => :bookmark_id
  
  private
  def update_cached_using!
    using.update_cached_bookmarks!
  end
  handle_asynchronously :update_cached_using!
end