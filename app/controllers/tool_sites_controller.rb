class ToolSitesController < ApplicationController
  respond_to :html, :json, :xml

  @@site_order = { "google" => "google_pagerank", 
                   "alexa" => "alexa_global_rank", 
                   "tools" => "tools_count", 
                   "sitename" => "title",
                   "jobs" => "jobs_count"
                 }

  # GET /tools
  def index
    @tool = Tool.find_by_cached_slug!(params[:tool_id])
    @usings = @tool.usings.joins(:site)
                          .includes(:site)
                          .order(build_order)
                          .paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 25)
    respond_with [@tool, @usings]
  rescue ActiveRecord::RecordNotFound
    redirect_to tools_path, :flash => { :error => "Unable to find a tool matching #{params[:id]}" }
  end
  
  # GET /tools/new
  def new
    @tool = Tool.find_by_cached_slug(params[:tool_id])
  end
  
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
    @tool = Tool.find_by_cached_slug(params[:tool_id])
    tags = Site.limit(50)
               .order('alexa_global_rank')
               .select([:id, :title, :url])
               .where(['sites.url LIKE ? OR sites.title LIKE ?', "#{params[:q]}%", "#{params[:q]}%"]).collect do |site|
      { "name" => "#{site.title} (#{site.url})", "id" => site.id.to_s }
    end.compact
    render :json => (tags - @tool.sites_hash)
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