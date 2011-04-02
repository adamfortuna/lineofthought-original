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
      tags = Tool.autocomplete(params[:term]).collect do |tool|
        { "name" => tool.name, 
          "id" => tool.id.to_s,
          "url" => tool.url,
          "categories" => tool.cached_categories.collect { |c| c[:name]}.join(", "),
          "icon" => tool.has_favicon? ? tool.full_favicon_url : nil }
      end
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
end