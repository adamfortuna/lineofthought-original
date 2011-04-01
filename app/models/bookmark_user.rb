class BookmarkUser < Bookmark
  belongs_to :parent, :class_name => "Bookmark", :primary_key => :parent_id, :counter_cache => 'user_bookmarks_count'
  belongs_to :user, :counter_cache => 'bookmarks_count'
                     
  # Can only save each bookmark once
  validates_uniqueness_of :user_id, :scope => :parent_id
  
  # Updates the various values of this bookmark based on what people have tagged it with
  def reindex
    self.cached_tools = []
    self.tools.each do |tool|
      self.cached_tools << { :id => tool.id, :name => tool.name, :param => tool.cached_slug }
    end
    
    self.cached_sites = []
    self.sites.each do |site|
      self.cached_sites << { :id => site.id, :name => site.name, :param => site.cached_slug }
    end
    self.cached_connections = []
  end

  def annotations_changed?
    previous_tool_ids = self.cached_tools.collect { |t| t[:id] }
    current_tool_ids = tool_ids.sort
    return true if current_tool_ids != previous_tool_ids
    return false
  end

  after_update :update_bookmark_cache, :if => :annotations_changed?  
  after_create :update_bookmark_cache
  after_destroy :update_bookmark_cache
  def update_bookmark_cache
    parent.reindex!
    self.reindex!
  end
  handle_asynchronously :update_bookmark_cache
end