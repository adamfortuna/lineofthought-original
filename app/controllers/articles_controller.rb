class ArticlesController < ApplicationController
  before_filter :load_or_redirect_by_url, :only => [:new]
  before_filter :load_or_url, :only => [:edit, :update]
  respond_to :html, :json, :xml

  def index
    @articles = Article.order("created_at desc")
                 .paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 10)
    respond_with(@articles)
  end

  def new
    params[:article] ||= {}
    @article ||= Article.new(:url => params[:article][:url], :title => params[:article][:title])
  end

  def create
    @article = Article.create(params[:article])
    if @article.new_record?
      flash[:error] = "There was a problem creating this article."
      render :new
    else
      redirect_to @article
    end
  end
  
  def show
    @article = Article.find_by_cached_slug(params[:id])
    respond_with(@article)
  end

  private
  def load_record; end
  
  def load_or_redirect_by_url
    return true unless params[:url] && params[:url]
    friendly_url = FriendlyUrl.new(params[:article][:url])
    @article = Article.find_by_friendly_url(friendly_url)
  end
end