class BookmarkUser < Bookmark
  belongs_to :bookmark, :primary_key => :parent_id, :counter_cache => 'user_bookmarks_count'
  belongs_to :user, :counter_cache => 'bookmarks_count'
  has_many :bookmark_annotations, :dependent => :destroy, :primary_key => :parent_id, :foreign_key => :bookmark_id
  has_many :user_bookmark_annotations, :class_name => "BookmarkAnnotation", :dependent => :destroy, :foreign_key => :user_bookmark_id
  has_many :sites, :through => :user_bookmark_annotations, :source => :site,
                   :conditions => "bookmark_annotations.annotateable_type = 'Site'"
  has_many :tools, :through => :user_bookmark_annotations, :source => :tool,
                   :conditions => "bookmark_annotations.annotateable_type = 'Tool'"
                     
  # Can only save each bookmark once
  validates_uniqueness_of :parent_id, :scope => :user_id
  
  def tool_ids=(ids)
    transaction do
      self.cached_tools = []
      if !new_record?
        BookmarkAnnotation.destroy_all ["user_bookmark_id = ? AND bookmark_id = ? AND annotateable_type=? AND annotateable_id NOT IN (?)", id, parent_id, 'Tool', ids]
      end
      Tool.where(["id IN (?)", ids]).each  do |tool|
        if new_record? || !user_bookmark_annotations.exists?(["bookmark_id=? AND annotateable_type=? AND annotateable_id = ?", parent_id, 'Tool', tool.id])
          self.user_bookmark_annotations.build({:annotateable => tool, :bookmark_id => parent_id})
        end
        self.cached_tools << { :id => tool.id, :name => tool.name, :param => tool.cached_slug }
      end
    end
  end
  
  # Updates the various values of this bookmark based on what people have tagged it with
  def reindex    
    self.tool_ids = self.tool_ids
    self.site_ids = self.site_ids
    self.cached_connections = []
  end
  
  def reindex!
    reindex
    save
  end
  
  private
  after_create :update_bookmark_cache
  after_destroy :update_bookmark_cache
  def update_bookmark_cache
    bookmark.reindex!
    self.reindex!
  end
  handle_asynchronously :update_bookmark_cache
end