class SiteBookmarksController < ApplicationController
  before_filter :load_record
  before_filter :authenticate_user!, :only => [:new, :create]
  respond_to :html, :json, :xml

  # GET /sites/:site_id/bookmarks/new
  def new
    @bookmark = @site.bookmarks.build(params[:bookmark])
  end
  
  # POST /bookmarks
  def create
    @link = Link.find_or_create_by_url(params[:bookmark][:url])
    @using = @site.usings.find(params[:using_id]) if params[:using_id]
    respond_to do |format|
      format.js do
        if @link.nil?
          render "bookmarks/create_failed"
        elsif (@bookmark = @link.bookmark) || (@link.parsed? && (@bookmark = BookmarkUser.new_from_link(@link)) && @bookmark.save)
          if @using
            @bookmark.connect!(@using)
            @using.reload
          end
          render :form
        elsif @link.unparseable? || @link.unreachable?
          render "bookmarks/create_failed"
        else
          render :js => "console.log('create in progress');"
        end
      end
    end
  end
  
  private
  def find(cached_slug)
    @site.bookmarks.find_by_cached_slug(cached_slug)
  end
  
  def load_record
    @site = Site.find_by_cached_slug(params[:site_id])
  end
end