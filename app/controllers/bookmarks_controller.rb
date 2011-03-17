class BookmarksController < ApplicationController
  before_filter :load_or_redirect_by_url, :only => [:new]
  before_filter :load_or_url, :only => [:edit, :update]
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
    @bookmark ||= Bookmark.new(:url => params[:bookmark][:url], :title => params[:bookmark][:title])
  end

  # POST /bookmarks/lookup
  def lookup
    link = Link.find_or_create_by_url(params[:tool][:url], true)
    if !link.parsed
      Timeout::timeout(20) do
        link.load_by_url_without_delay
      end
    end
    respond_to do |format|
      format.js do
        if link.source
          render :js => "alert('already exists');"
        elsif link.parsed?
          @tool = Tool.new_from_link(link)
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
  
  def show
    @bookmark = Bookmark.find_by_cached_slug(params[:id])
    respond_with(@bookmark)
  end

  private
  def load_record; end
  
  def load_or_redirect_by_url
    return true unless params[:url] && params[:url]
    handy_url = HandyUrl.new(params[:bookmark][:url])
    @bookmark = Bookmark.find_by_handly_url(handy_url)
  end
end