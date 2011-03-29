class BookmarksController < ApplicationController
  before_filter :authenticate_user!, :only => [:new, :create]
  before_filter :load_or_redirect_by_url, :only => [:new]
  respond_to :html, :json, :xml

  caches_action :show, :cache_path => Proc.new { |controller| controller.params.merge(:logged_in => logged_in?, :claimed => (logged_in? && (current_user.admin? || current_user.claimed_tool?(params[:id])) ? true : false) ) }, :expires_in => 1.hour

  # GET /bookmarks
  def index
    begin
      @search = Sunspot.search(Bookmark) do
        keywords params[:search] if params[:search]
        order_by(:created_at, :desc)
        paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 20)
      end
      @bookmarks = @search.results
      @hits = @search.hits
      debugger
      puts "Loaded bookmarks from Solr"
    # Can't connect to solr, fallback on SQL.
    # Note: no search ability while solr is down.
    rescue Errno::ECONNREFUSED
      puts "Unable to Connect to Solr to retreive bookmarks. Falling back on SQL."
      @bookmarks = Bookmark.order("created_at desc")
                   .paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 20)
      @hits = @bookmarks
    end
    respond_with(@bookmarks)
  end

  # GET /bookmarks/new
  def new
    params[:bookmark] ||= {}
    url = params[:bookmark][:url]
    if url
      @link = Link.find_or_create_by_url(url)
      @bookmark = Bookmark.new_from_link(@link)
    else
      @bookmark = Bookmark.new(params[:bookmark])
    end
  end

  # POST /bookmarks
  def create
    @link = Link.find_or_create_by_url(params[:bookmark][:url])
    respond_to do |format|
      format.js do
        if @link.nil?
          render :create_failed
        elsif @bookmark = @link.bookmark
          render :create_success
        elsif @link.parsed? && (@bookmark = Bookmark.create_from_link(@link)) && !@bookmark.new_record?
          render :create_success
        elsif (@bookmark && @bookmark.new_record?) || @link.unparseable? || @link.unreachable?
          render :create_failed
        else
          render :js => "console.log('create in progress');"
        end
      end
    end
  end

  def edit
    @bookmark = Bookmark.find_by_cached_slug(params[:id])
  end

  def update
    @bookmark = Bookmark.find_by_cached_slug(params[:id])
    if @bookmark.update_attributes(params[:bookmark])
      redirect_to @bookmark, :notice => "This bookmark was updated."
    else
      flash[:error] = "There was an error updating this bookmark"
      render :edit
    end
  end
  
  def show
    @bookmark = Bookmark.find_by_cached_slug(params[:id])
    respond_with(@bookmark)
  end

  def destroy
    @bookmark = Bookmark.find_by_cached_slug(params[:id])
    if @bookmark.destroy
      redirect_to bookmarks_path, :notice => "This bookmark was removed."
    else
      flash[:error] = "There was a problem removing this bookmark."
      redirect_to @bookmark
    end
  end

  private
  def load_record; end
  
  def load_or_redirect_by_url
    return true unless params[:url] && params[:url]
    handy_url = HandyUrl.new(params[:bookmark][:url])
    @bookmark = Bookmark.find_by_handly_url(handy_url)
  end
end