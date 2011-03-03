class ToolSitesController < ApplicationController
  respond_to :html, :json, :xml

  @@site_order = { "google" => "google_pagerank", 
                   "alexa" => "alexa_global_rank", 
                   "tools" => "tools_count", 
                   "sitename" => "title",
                   "jobs" => "jobs_count"
                 }

  def index
    @tool = Tool.find_by_cached_slug(params[:tool_id])
    @usings = @tool.usings.joins(:site)
                          .includes(:site)
                          .order(build_order)
                          .paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 25)
    respond_with [@tool, @usings]
  end
  
  def new
    @tool = Tool.find_by_cached_slug(params[:tool_id])
  end

  # POST /tools/:tool_id/sites
  def create
    @tool = Tool.find_by_cached_slug(params[:tool_id])
    @tool.add_sites!(params[:tool][:csv])
    redirect_to new_tool_site_path(@tool), :notice => "We're processing your tools. They should be added soon!"
  end

  private
  def build_order
    params[:sort] ||= "alexa_asc"
    order = params[:sort]
    sort_order = @@site_order[order.split("_").first] rescue "alexa_global_rank"
    direction = order.split("_").last rescue "asc"
    return "#{sort_order} #{direction}, sites.title"    
  end
end