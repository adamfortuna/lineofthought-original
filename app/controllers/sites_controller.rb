class SitesController < ApplicationController
  before_filter :load_record, :only => [:edit, :update, :destroy]
  before_filter :redirect_to_site_tools, :only => [:new]
  respond_to :html, :json, :xml

  caches_action :show, :cache_path => Proc.new { |controller| controller.params.merge(:logged_in => logged_in?, :claimed => (logged_in? && (current_user.admin? || current_user.claimed_site?(params[:id])) ? true : false) ) }, :expires_in => 2.minutes

  @@order = { "google" => "google_pagerank", 
              "alexa" => "alexa_global_rank", 
              "tools" => "tools_count", 
              "sitename" => "lower_title",
              "bookmarks" => "bookmarks_count"
            }

  @@tool_order = { "sites" => "sites_count", 
                   "toolname" => "tools.name",
                   "bookmarks" => "tools.bookmarks_count",
                   "jobs" => "tools.jobs_count" }

  # GET /sites
  def index
    @search = Site.search do
      keywords params[:search] if params[:search]
      order_by(order_field.to_sym, order_direction.to_sym)
      paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 30)
    end
    respond_with(@search.results)
  end

  # GET /sites/:id
  def show
    @site = Site.find_by_cached_slug!(params[:id]) 
    @usings = @site.usings.includes([:tool, :site]).joins(:tool).order(build_tool_order)
    respond_with(@site)
  rescue ActiveRecord::RecordNotFound
    redirect_to sites_path, :flash => { :error => "Unable to find a site matching #{params[:id]}" }
  end

  # GET /sites/new
  def new
    @site = Site.new(params[:site])
    respond_with(@site)
  end
  
  # POST /sites/lookup
  def lookup
    link = Link.find_or_create_by_domain(params[:site][:url], true)
    if !link.parsed
      Timeout::timeout(20) do
        link.parse_html_without_delay
      end
    end
    respond_to do |format|
      format.js do
        if @site = link.site
          render :duplicate
        elsif link.parsed?
          @site = Site.new_from_link(link)
          render :lookup_complete
        else
          render :js => ""
          # no response, lookup in progress
        end
      end
    end
  end

  # POST /sites
  def create
    @site = Site.create(params[:site])
    if @site.new_record?
      debugger
      flash[:error] = "There was a problem creating this site."
      render :new
    else
      respond_to do |format|
        format.html { redirect_to @site }
        format.popup { redirect_to manage_site_tools_path(@site, :format => :popup) }
      end
    end
  end
  
  # GET /sites/:id/edit
  def edit
    @site = Site.find_by_cached_slug(params[:id]) 
    respond_with(@site)
  rescue ActiveRecord::RecordNotFound
    redirect_to sites_path, :flash => { :error => "Unable to find a site matching #{params[:id]}" }
  end
  
  # PUT /sites/:id
  def update
    @site = Site.find_by_cached_slug(params[:id])
    if @site.update_attributes(params[:site])
      redirect_to @site
    else
      flash[:error] = "There was a problem updating this site."
      render :edit
    end
  end
  
  def autocomplete
    sites = Site.limit(25)
               .order('updated_at DESC')
               .select([:id, :title, :url])
               .where(['sites.title LIKE ? OR sites.url LIKE ?', "#{params[:q]}%", "%#{params[:q]}%"]).collect do |site|
      { "name" => "#{site.title} (#{site.url})", "id" => site.id.to_s }
    end
    render :json => sites
  end

  def destroy
    if @site.destroy
      flash[:notice] = "Delete successful"
      redirect_to sites_path
    else
      flash[:error] = "There was a problem deleting this site."
      redirect_to site_path(@site)
    end
  end

  def claim
    @site = Site.find_by_cached_slug(params[:id])
  end
  
  def bookmarks
    @site = Site.find_by_cached_slug(params[:id])
  end

  private
  def load_record
    @site = Site.find_by_cached_slug(params[:id])
  end
  
  def build_order
    params[:sort] ||= "alexa_asc"
    order = params[:sort]
    sort_order = @@order[order.split("_").first] rescue "alexa_global_rank"
    direction = order.split("_").last rescue "asc"
    return "#{sort_order} #{direction}"
  end
  
  def order_field
    build_order.split(" ").first
  end

  def order_direction
    build_order.split(" ").last
  end
  
  def build_tool_order
    params[:sort] ||= "sites_desc"
    order = params[:sort]
    sort_order = @@tool_order[order.split("_").first] rescue "sites_count"
    direction = order.split("_").last rescue "desc"
    return "#{sort_order} #{direction}"
  end

  def redirect_to_site_tools
    return true unless params[:site] && params[:site][:url]
    url = HandyUrl.new(params[:site][:url])
    site = Site.find_by_uid(url.uid)
    redirect_to manage_site_tools_path(site, :format => params[:format]) if site
  end
end