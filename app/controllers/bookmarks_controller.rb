class BookmarksController < ApplicationController
  before_filter :load_or_redirect_by_url, :only => [:new]
  respond_to :html, :json, :xml

  # GET /bookmarks
  def index
    @bookmarks = Bookmark.order("created_at desc")
                 .paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 10)
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

  # POST /bookmarks/lookup
  def lookup
    link = Link.find_or_create_by_url(params[:bookmark][:url], true)
    if !link.parsed
      Timeout::timeout(5) do
        link.load_by_url_without_delay
      end
    end
    respond_to do |format|
      format.js do
        if link.source
          render :js => "alert('already exists');"
        elsif link.parsed?
          @bookmark = Bookmark.new_from_link(link)
          render :lookup_complete
        else
          render :js => ""
          # no response, lookup in progress
        end
      end
    end
  rescue
    render :js => ""    
  end
  
  # POST /bookmarks
  def create
    @bookmark = Bookmark.create(params[:bookmark])
    if @bookmark.new_record?
      flash[:error] = "There was a problem creating this bookmark."
      render :new
    else
      redirect_to @bookmark
    end
  end

  def edit
    @bookmark = Bookmark.find_by_cached_slug(params[:id])
  end
  
  def show
    @bookmark = Bookmark.find_by_cached_slug(params[:id])
    respond_with(@bookmark)
  end
  
  def sites
    @bookmark = Bookmark.find_by_cached_slug(params[:id])
    respond_with([@bookmark, @bookmark.sites, @bookmark.usings])
  end

  def tools
    @bookmark = Bookmark.find_by_cached_slug(params[:id])
    respond_with([@bookmark, @bookmark.tools, @bookmark.usings])
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