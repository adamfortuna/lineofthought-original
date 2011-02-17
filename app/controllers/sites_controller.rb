class SitesController < ApplicationController
  before_filter :load_record, :only => [:edit, :update]
  before_filter :redirect_to_site_tools, :only => [:new]
  respond_to :html, :json, :xml
  caches_action :index, :cache_path => Proc.new { |controller| controller.params }, :expires_in => 5.minutes
  caches_action :show, :cache_path => Proc.new { |controller| controller.params }, :expires_in => 5.minutes

  @@order = { "google" => "google_pagerank", 
              "alexa" => "isnull(alexa_global_rank), alexa_global_rank", 
              "tools" => "tools_count", 
              "sitename" => "title"
            }

  def index
    @sites = Site.order(build_order)
                 .paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 10)
    respond_with(@sites)
  end

  def show
    @site = Site.find_by_cached_slug(params[:id]) 
    @usings = @site.usings.includes(:tool).joins(:tool).order("sites_count desc")
    respond_with(@site)
  end

  def new
    @site = Site.new(params[:site])
    respond_with(@site)
  end

  def create
    @site = Site.create(params[:site])
    if @site.new_record?
      flash[:error] = "There was a problem creating this site."
      render :new
    else
      respond_to do |format|
        format.html { redirect_to @site }
        format.popup { redirect_to edit_site_tools_path(@site, :format => :popup) }
      end
    end
  end
  
  def edit
    @site = Site.find_by_cached_slug(params[:id]) 
    respond_with(@site)
  end
  
  def update
    @site = Site.find_by_cached_slug(params[:id]) 
    if @site.update_attributes(params[:site])
      redirect_to @site
    else
      flash[:error] = "There was a problem updating this site."
      render :edit
    end    
  end

  private
  def load_record; end
  
  def build_order
    params[:sort] ||= "alexa_asc"
    order = params[:sort]
    sort_order = @@order[order.split("_").first] rescue "alexa_global_rank"
    direction = order.split("_").last rescue "asc"
    return "#{sort_order} #{direction}"
  end
  
  def redirect_to_site_tools
    return true unless params[:site] && params[:site][:url]
    url = FriendlyUrl.new(params[:site][:url])
    site = Site.find_by_url(url.to_s)
    redirect_to edit_site_tools_path(site, :format => params[:format]) if site
  end
end