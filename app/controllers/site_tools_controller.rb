class SiteToolsController < ApplicationController
  before_filter :authenticate_user!, :only => [:manage, :create]
  before_filter :load_record, :only => [:create, :manage, :autocomplete]
  respond_to :html, :json, :xml
  cache_sweeper :using_sweeper, :only => [:create]

  @@order = { "sites" => "sites_count", 
              "toolname" => "tools.name",
              "bookmarks" => "tools.bookmarks_count",
              "jobs" => "tools.jobs_count" }

  # GET /sites/:site_id/tools/:id
  def show
    @site = Site.find_by_cached_slug!(params[:site_id]) 
    @tool = Tool.find_by_cached_slug!(params[:id]) 
    @using = @site.usings.where(:tool_id => @tool.id).first
  rescue ActiveRecord::RecordNotFound
    redirect_to sites_path, :flash => { :error => "Unable to find a site matching #{params[:id]}" }
  end

  # GET /sites/:site_id/tools/manage
  def manage
    @usings = @site.usings.all(:include => :tool, :order => "tools.name")
    respond_to do |format|
      format.html
      format.popup
    end
  end
  
  # POST /sites/:site_id/tools
  def create
    respond_to do |format|
      format.js {
        if @using = @site.usings.create(params[:using].merge(:user_id => current_user.id))
          render
        else
          render :js => "alert('problem');"
        end
      }
    end   
  end

  # GET /sites/:site_id/tools/autocomplete
  def autocomplete
    @site = Site.find_by_cached_slug(params[:site_id])
    tags = Tool.autocomplete(params[:q]).collect do |tool|
      { "name" => "#{tool.name}#{" (#{tool.cached_language[:name]})" if tool.cached_language}", "id" => tool.id.to_s }
    end
    render :json => (tags - @site.tools_hash)
  end


  private
  def load_record
    @site = Site.find_by_cached_slug(params[:site_id])
  end
end