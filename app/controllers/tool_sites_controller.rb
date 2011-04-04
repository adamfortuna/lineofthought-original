class ToolSitesController < ApplicationController
  before_filter :authenticate_user!, :only => [:manage, :create]
  respond_to :html, :json, :xml
  # cache_sweeper :using_sweeper, :only => [:create]
  
  # GET /tools/:tool_id/sites/manage
  def manage
    @tool = Tool.find_by_cached_slug(params[:tool_id])
    @usings = @tool.usings.all(:include => :site, :order => "sites.title")
    respond_to do |format|
      format.html
      format.popup
    end
  end

  # POST /tools/:tool_id/sites
  def create
    @tool = Tool.find_by_cached_slug(params[:tool_id])
    params[:using][:site_id] = Site.create_from_url(params[:using][:site_id]) unless params[:using][:site_id].to_i > 0
    respond_to do |format|
      format.js {
        if @using = @tool.usings.create(params[:using].merge(:user_id => current_user.id))
          render
        else
          render :js => "alert('problem');"
        end
      }
    end   
  end
  
  # GET /tools/:tool_id/sites/autocomplete
  def autocomplete
    tags = Site.autocomplete(params[:q]).collect do |site|
      { "name" => "#{site.title} (#{site.url})", "id" => site.id.to_s }
    end.compact
    @tool = Tool.find_by_cached_slug(params[:tool_id])

    render :json => (tags - @tool.sites_hash)
  end
end