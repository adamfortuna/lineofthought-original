class SitesController < ApplicationController
  before_filter :redirect_to_site_tools, :only => [:new]
  before_filter :authenticate_user!, :only => [:destroy, :claim]
  before_filter :load_record, :only => [:edit, :update, :destroy]
  before_filter :verify_edit_access!, :only => [:edit, :update]
  before_filter :verify_delete_access!, :only => [:delete]
  respond_to :html, :json, :xml
  
  cache_sweeper :site_sweeper, :only => [:create, :update, :destroy]
  # caches_action :show, :if => Proc.new { |controller| !logged_in? && params[:page].nil?  && params[:per_page].nil? }, :expires_in => 1.hour, :layout => false
  caches_action :index, :if => Proc.new { |controller| !logged_in? && params[:sort].nil? && params[:search].nil? && params[:page].nil?  && params[:per_page].nil? }, :expires_in => 1.hour, :layout => false

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
    respond_with([@site, @usings])
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
    @link = Link.find_or_create_by_domain(params[:site][:url]) if params[:site] && !params[:site][:url].blank?
    respond_to do |format|
      format.js do
        if @link.nil?
          render :create_failed
        elsif @site = @link.site
          render :duplicate
        elsif @link.parsed? && (@site = Site.create_from_link(@link, current_user)) && !@site.new_record?
          flash[:notice] = "Your site was added to Line of Thought. You can now add some tools it uses, or edit it."
          session[:site_ids] ||= []
          session[:site_ids] << @site.id
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
    respond_with(@site)
  rescue ActiveRecord::RecordNotFound
    redirect_to sites_path, :flash => { :error => "Unable to find a site matching #{params[:id]}" }
  end
  
  # PUT /sites/:id
  def update
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
  
  def load_record
    @site = find(params[:id]) 
  end

  def verify_edit_access!
    if !can_edit_site?(@site)
      flash[:error] = "You do not have access to edit this site."
      redirect_to site_path(@site)
    end
  end

  def verify_delete_access!
    if !current_user.can_destroy_site?(@site)
      flash[:error] = "You do not have access to delete this site."
      redirect_to site_path(@site)
    end
  end
end