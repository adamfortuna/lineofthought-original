class SitesController < ApplicationController
  before_filter :redirect_to_site_tools, :only => [:new]
  before_filter :authenticate_user!, :only => [:new, :create, :edit, :update, :destroy, :claim]
  respond_to :html, :json, :xml
  
  cache_sweeper :site_sweeper, :only => [:create, :update, :destroy]
  # caches_action :show, :cache_path => Proc.new { |controller| controller.params.merge(:logged_in => logged_in?, :claimed => (logged_in? && current_user && (current_user.admin? || current_user.claimed_site?(params[:id])) ? true : false) ) }, :expires_in => 12.hours

  # GET /sites
  def index
    params[:sort] ||= "alexa_asc"
    @sites, @hits, loaded_from_solr = Site.search_by_params(params)
    if !loaded_from_solr && params[:search]
      params[:search] = nil
      flash[:error] = "Sorry, search is not available at the moment. Usually this means Solr is down :/ Please try again later."
    end
    respond_with(@sites)
  end

  # GET /sites/:id
  def show
    @site = find(params[:id]) 
    params[:sort] ||= "sites_desc"
    @usings = @site.usings.includes(:tool).joins(:tool).order(Tool.sql_order(params[:sort]))
    respond_with(@site)
  rescue ActiveRecord::RecordNotFound
    redirect_to sites_path, :flash => { :error => "Unable to find a site matching #{params[:id]}" }
  end

  # GET /sites/new
  def new
    @site = Site.new(params[:site])
    respond_with(@site)
  end

  # POST /sites
  def create
    @link = Link.find_or_create_by_domain(params[:site][:url])
    respond_to do |format|
      format.js do
        if @link.nil?
          render :create_failed
        elsif @site = @link.site
          render :duplicate
        elsif @link.parsed? && (@site = Site.create_from_link(@link, current_user)) && !@site.new_record?
          render :create_success
        elsif (@site && @site.new_record?) || @link.unparseable? || @link.unreachable?
          render :create_failed
        else
          render :js => "console.log('create in progress');"
        end
      end
    end
  end
  
  # GET /sites/:id/edit
  def edit
    @site = find(params[:id]) 
    respond_with(@site)
  rescue ActiveRecord::RecordNotFound
    redirect_to sites_path, :flash => { :error => "Unable to find a site matching #{params[:id]}" }
  end
  
  # PUT /sites/:id
  def update
    @site = find(params[:id]) 
    if @site.update_attributes(params[:site])
      redirect_to @site
    else
      flash[:error] = "There was a problem updating this site."
      render :edit
    end
  end
  
  def autocomplete
    tags = Site.autocomplete(params[:q]).collect do |site|
      { "name" => "#{site.title} (#{site.url})", "id" => site.id.to_s }
    end.compact
    render :json => tags
  end

  def destroy
    @site = find(params[:id]) 
    if @site.destroy
      flash[:notice] = "Delete successful"
      redirect_to sites_path
    else
      flash[:error] = "There was a problem deleting this site."
      redirect_to site_path(@site)
    end
  end

  def claim
    @site = find(params[:id]) 
  end
  
  def bookmarks
    @site = find(params[:id]) 
    @bookmarks = @tool.bookmarks.order("created_at desc")
                                .paginate(:per_page => params[:per_page] || 20,
                                          :page => params[:page])
    respond_with([@site, @bookmarks])
    
  end

  private
  def find(cached_slug)
    Site.find_by_cached_slug!(cached_slug)
  end
  
  def redirect_to_site_tools
    return true unless params[:site] && params[:site][:url]
    url = HandyUrl.new(params[:site][:url])
    site = Site.find_by_uid(url.uid)
    redirect_to manage_site_tools_path(site, :format => params[:format]) if site
  end
end