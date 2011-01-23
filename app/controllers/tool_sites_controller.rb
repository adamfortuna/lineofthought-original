class ToolSitesController < ApplicationController
  respond_to :html, :json, :xml
  caches_action :index, :cache_path => Proc.new { |controller| controller.params }, :expires_in => 15.minutes

  @@site_order = { "google" => "google_pagerank", 
                   "alexa" => "alexa_global_rank", 
                   "tools" => "tools_count", 
                   "sitename" => "title"
                 }

  def index
    @tool = Tool.find_by_cached_slug(params[:tool_id])
    @usings = @tool.usings.joins(:site)
                          .includes(:site)
                          .order(build_order)
                          .paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 25)
    respond_with [@tool, @usings]
  end

  private
  def build_order
    params[:sort] ||= "alexa_asc"
    order = params[:sort]
    sort_order = @@site_order[order.split("_").first] rescue "alexa_global_rank"
    direction = order.split("_").last rescue "asc"
    return "#{sort_order} #{direction}"    
  end
end