class BookmarksController < ApplicationController
  before_filter :authenticate_user!, :only => [:new, :create]
  before_filter :load_or_redirect_by_url, :only => [:new]
  respond_to :html, :json, :xml

  caches_action :show, :cache_path => Proc.new { |controller| controller.params.merge(:logged_in => logged_in?, :claimed => (logged_in? && (current_user.admin? || current_user.claimed_tool?(params[:id])) ? true : false) ) }, :expires_in => 1.hour

  # GET /bookmarks
  def index
    @bookmarks, @hits, loaded_from_solr = Bookmark.search_by_params(params)
    if !loaded_from_solr && params[:search]
      params[:search] = nil
      flash[:error] = "Sorry, search is not available at the moment. Usually this means Solr is down :/ Please try again later."
    end
    respond_with(@bookmarks)
  end

  # GET /bookmarks/:id
  def show
    @bookmark = find(params[:id])
    respond_with(@bookmark)
  end

  # GET /bookmarks/new
  # Form for adding the first bookmark at a current URL.
  # Will be redirected to the save bookmark form if the URL they're 
  # entering already exists as a bookmark.
  def new
    params[:bookmark] ||= {}
    url = params[:bookmark][:url]
    if url
      @link = Link.find_or_create_by_url(url)
      if @link.bookmark
        redirect_to new_bookmark_save_url(@link.bookmark)
      else
        @bookmark = Bookmark.new_from_link(@link)
      end
    else
      @bookmark = Bookmark.new(params[:bookmark])
    end
  end
  
  # POST /bookmarks/lookup
  def lookup
    @link = Link.find_or_create_by_url(params[:bookmark][:url])
    respond_to do |format|
      format.js do
        if @link.nil?
          render :lookup_failed
        elsif @bookmark = @link.bookmark
          render :lookup_exists
        elsif @link.parsed? && (@bookmark = BookmarkUser.new_from_link(@link))
          render :lookup_complete
        elsif @link.unparseable? || @link.unreachable?
          render :lookup_failed
        else
          render :js => "console.log('create in progress');"
        end
      end
    end
  end

  # Admins only
  def edit
    @bookmark = find(params[:id])
  end

  # Admins only
  def update
    @bookmark = find(params[:id])
    if @bookmark.update_attributes(params[:bookmark])
      redirect_to @bookmark, :notice => "This bookmark was updated."
    else
      flash[:error] = "There was an error updating this bookmark"
      render :edit
    end
  end

  # Admins only
  def destroy
    @bookmark = find(params[:id])
    if @bookmark.destroy
      redirect_to bookmarks_path, :notice => "This bookmark was removed."
    else
      flash[:error] = "There was a problem removing this bookmark."
      redirect_to @bookmark
    end
  end

  private
  def find(cached_slug)
    Bookmark.find_by_cached_slug(cached_slug)
  end
  
  def load_or_redirect_by_url
    return true unless params[:url] && params[:url]
    handy_url = HandyUrl.new(params[:bookmark][:url])
    @bookmark = Bookmark.find_by_handly_url(handy_url)
  end
end