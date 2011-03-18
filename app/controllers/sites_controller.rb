class SitesController < ApplicationController
  # Logged in: claim, edit, new, create
  before_filter :load_record, :only => [:edit, :update, :destroy]
  before_filter :redirect_to_site_tools, :only => [:new]
  respond_to :html, :json, :xml
  caches_action :index, :cache_path => Proc.new { |controller| controller.params.merge(:logged_in => logged_in? ) }, :expires_in => 15.minutes
  caches_action :show, :cache_path => Proc.new { |controller| controller.params.merge(:logged_in => logged_in?, :claimed => (logged_in? && (current_user.admin? || current_user.claimed_site?(params[:id])) ? true : false) ) }, :expires_in => 15.minutes

  @@order = { "google" => "google_pagerank", 
              "alexa" => "coalesce(alexa_global_rank, 100000000)", 
              "tools" => "tools_count", 
              "sitename" => "title",
              "bookmarks" => "sites.bookmarks_count"
            }

  def index
    @sites = Site.order(build_order)
                 .paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 10)
    respond_with(@sites)
  end

  def show
    @site = Site.find_by_cached_slug!(params[:id]) 
    @usings = @site.usings.includes(:tool).joins(:tool).order(:name)
    params[:sort] = "toolname"
    respond_with(@site)
  rescue ActiveRecord::RecordNotFound
    redirect_to sites_path, :flash => { :error => "Unable to find a site matching #{params[:id]}" }
  end

  def new
    @site = Site.new(params[:site])
    @site.load_by_url unless @site.url.blank?
    respond_with(@site)
  end

  def create
    @site = Site.create(params[:site])
    if @site.new_record?
      flash[:error] = "There was a problem creating this site."
      debugger
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
    @site.load_by_url if @site.description.blank?
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
  
  def redirect_to_site_tools
    return true unless params[:site] && params[:site][:url]
    url = HandyUrl.new(params[:site][:url])
    site = Site.find_by_uid(url.uid)
    redirect_to edit_site_tools_path(site, :format => params[:format]) if site
  end
end