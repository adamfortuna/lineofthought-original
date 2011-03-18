class BookmarkConnection < ActiveRecord::Base
  belongs_to :bookmark
  belongs_to :using, :counter_cache => 'bookmarks_count'
  after_create :update_cached_using!
  
  private
  def update_cached_using!
    using.update_cached_bookmarks!
  end
end