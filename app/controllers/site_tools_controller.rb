class SiteToolsController < ApplicationController
  before_filter :authenticate_user!, :only => [:create]
  before_filter :load_record, :only => [:create, :autocomplete]
  before_filter :verify_access_to_create!, :only => [:create]

  respond_to :html, :json, :xml
  # cache_sweeper :using_sweeper, :only => [:create]

  @@order = { "sites" => "sites_count", 
              "toolname" => "tools.name",
              "bookmarks" => "tools.bookmarks_count",
              "jobs" => "tools.jobs_count" }

  # GET /sites/:site_id/tools/:id
  def show
    @site = Site.find_by_cached_slug!(params[:site_id]) 
    @tool = Tool.find_by_cached_slug!(params[:id]) 
    @using = @site.usings.with_deleted.where(:tool_id => @tool.id).first
  rescue ActiveRecord::RecordNotFound
    redirect_to sites_path, :flash => { :error => "Unable to find a site matching #{params[:id]}" }
  end
  
  
  # GET /sites/:site_id/tools/deleted
  def deleted
    @site = Site.find_by_cached_slug!(params[:site_id]) 
    params[:sort] ||= "sites_desc"
    @usings = @site.usings.only_deleted.includes(:tool).joins(:tool).order(Tool.sql_order(params[:sort]))
  rescue ActiveRecord::RecordNotFound
    redirect_to sites_path, :flash => { :error => "Unable to find a site matching #{params[:id]}" }    
  end
  
  # POST /sites/:site_id/tools
  def create
    @using = @site.usings.create(params[:using].merge(:user_id => current_user.id))
    respond_to do |format|
      format.js {
        if @using.id
          render
        else
          render :create_failed
        end
      }
    end   
  end

  # GET /sites/:site_id/tools/autocomplete
  def autocomplete
    if params[:term]
      @site = Site.find_by_cached_slug(params[:site_id])
      tags = Tool.autocomplete(params[:term]).collect(&:autocomplete_data)
      tools = (tags - @site.tools_hash)
    else
      tools = []
    end
    render :json => tools
  end


  private
  def load_record
    @site = Site.find_by_cached_slug(params[:site_id])
  end

  def verify_access_to_create!
    if !current_user.can_add_lines?(@site)
      respond_to do |format|
        format.js { render :js => "alert('You do not have access to add new tools to this site.');" }
      end
    end
  end
end