class BookmarksController < ApplicationController
  before_filter :authenticate_user!, :only => [:new, :create]
  before_filter :load_or_redirect_by_url, :only => [:new]
  respond_to :html, :json, :xml

  # caches_action :show, :cache_path => Proc.new { |controller| controller.params.merge(:logged_in => logged_in?, :claimed => (logged_in? && (current_user.admin? || current_user.claimed_tool?(params[:id])) ? true : false) ) }, :expires_in => 1.hour

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
  
  # Admins only
  def edit
    @bookmark = find(params[:id])
  end

  # Admins only
  def update
    @bookmark = find(params[:id])
    @bookmark.update_attributes(params[:bookmark])
    
    respond_to do |format|
      format.html do
        if @bookmark.valid?
          redirect_to @bookmark, :notice => "This bookmark was updated."
        else
          flash[:error] = "There was an error updating this bookmark"
          render :edit
        end
      end
      format.js { render }
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