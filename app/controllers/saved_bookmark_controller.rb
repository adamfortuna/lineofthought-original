class SavedBookmarkController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :json, :xml

  # GET /bookmarks/:bookmark_id/save/new
  def new
    @bookmark = find_bookmark(params[:bookmark_id])
    @bookmark_user = find(@bookmark) || @bookmark.to_user
    if @bookmark_user.new_record?
      render :new
    else
      redirect_to edit_bookmark_save_path(@bookmark)
    end
  end
  
  # POST /bookmarks/:bookmark_id/save
  def create
    @bookmark = find_bookmark(params[:bookmark_id])
    user_bookmark_params = params[:bookmark_user].merge({ :parent_id => @bookmark.id,
                                                          :link_id => @bookmark.link_id,
                                                          :has_favicon => @bookmark.has_favicon,
                                                          :url => @bookmark.url })
    @bookmark_user = current_user.bookmarks.build(user_bookmark_params)
    if @bookmark_user.save
      redirect_to edit_bookmark_save_path(@bookmark), :flash => { :notice => "This bookmark was saved!" }
    else
      flash[:error] = "There was a problem saving this bookmark. Please check below and resubmit."
      render :new
    end
  end

  # GET /bookmarks/:bookmark_id/save/edit
  def edit
    @bookmark = find_bookmark(params[:bookmark_id])
    @bookmark_user = find(@bookmark)
    if !@bookmark_user
      redirect_to new_bookmark_save_path(@bookmark)
    else
      respond_with([@bookmark, @bookmark_user])
    end
  end

  # PUT /bookmarks/:bookmark_id/save
  def update
    @bookmark = find_bookmark(params[:bookmark_id])
    @bookmark_user = find(@bookmark)
    if @bookmark_user.update_attributes(params[:bookmark_user])
      @bookmark_user.update_bookmark_cache
      redirect_to edit_bookmark_save_path(@bookmark), :flash => { :notice => "This bookmark was updated!" }
    else
      flash[:error] = "There was a problem saving this bookmark. Please check below and resubmit."
      render :edit
    end
  end

  # DELETE /bookmarks/:bookmark_id/save
  def destroy
    @bookmark = find_bookmark(params[:bookmark_id])
  end

  private
  def find_bookmark(cached_slug)
    Bookmark.find_by_cached_slug(cached_slug)
  end
  def find(bookmark)
    current_user.bookmarks.find(:first, :conditions => ["parent_id = ?", bookmark.id])
  end
end