class BookmarkAnnotation < ActiveRecord::Base
  belongs_to :annotateable, :polymorphic => true, :counter_cache => 'bookmarks_count'
  belongs_to :site, :class_name => "Site", :foreign_key => "annotateable_id"
  belongs_to :tool, :class_name => "Tool", :foreign_key => "annotateable_id"
  belongs_to :bookmark

  validates_uniqueness_of :bookmark_id, :scope => [:annotateable_id, :annotateable_type]
  after_create :create_for_bookmark!, :if => :bookmark_for_user?
  after_create :update_caches!
  after_destroy :update_caches!

  scope :for_tools, where("annotateable_type='Tool'")
  scope :for_sites, where("annotateable_type='Site'")

  def bookmark_for_user?
    !bookmark.parent_id.nil?
  end

  private
  def update_caches!
    puts "create_for_bookmark"
    annotateable.update_bookmarks!
  end
  handle_asynchronously :update_caches!
  
  def create_for_bookmark!
    puts "create_for_bookmark"
    if annotateable_type == 'Tool'
      if !bookmark.has_tool?(annotateable_id)
        bookmark.parent.annotations.create({ :annotateable => self.annotateable,
                                             :description => self.description})
      end
    elsif annotateable_type == 'Site'
      if !bookmark.has_site?(annotateable_id)
        bookmark.parent.annotations.create({ :annotateable => self.annotateable,
                                             :description => self.description})
      end
    end
  end
  handle_asynchronously :create_for_bookmark!  
end