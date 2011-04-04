class ToolSitesController < ApplicationController
  before_filter :authenticate_user!, :only => [:create]
  before_filter :load_record, :only => [:create, :autocomplete]
  before_filter :verify_access_to_create!, :only => [:create]
  respond_to :html, :json, :xml
  # cache_sweeper :using_sweeper, :only => [:create]
  
  # GET /tools/:site_id/sites/deleted
  def deleted
    @tool = Tool.find_by_cached_slug!(params[:tool_id]) 
    params[:sort] ||= "alexa_asc"
    # Todo: Not sure why the 2nd one stopped working
    @usings = Using.only_deleted
                   .where(["tool_id=?", @tool.id])
                   .includes(:site)
                   .joins(:site)
                   .order(Site.sql_order(params[:sort]))
                   .paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 20)

    # @usings = @tool.usings
    #                .only_deleted
    #                .includes(:site)
    #                .joins(:site)
    #                .order(Site.sql_order(params[:sort]))
    #                .paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 20)
  rescue ActiveRecord::RecordNotFound
    redirect_to sites_path, :flash => { :error => "Unable to find a tool matching #{params[:id]}" }    
  end

  # POST /tools/:tool_id/sites
  def create
    @using = @tool.usings.create(params[:using].merge(:user_id => current_user.id))
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
  
  # GET /tools/:tool_id/sites/autocomplete
  def autocomplete
    if params[:term]
      @tool = Tool.find_by_cached_slug(params[:tool_id])
      tags = Site.autocomplete(params[:term]).collect(&:autocomplete_data)
      tools = (tags - @tool.sites_hash)
    else
      tools = []
    end
    render :json => tools
  end
  
  private
  def load_record
    @tool = Tool.find_by_cached_slug(params[:tool_id])
  end

  def verify_access_to_create!
    if !current_user.can_add_lines?(@tool)
      respond_to do |format|
        format.js { render :js => "alert('You do not have access to add new sites for this tool.');" }
      end
    end
  end
end