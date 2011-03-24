class ToolsController < ApplicationController
  before_filter :load_record, :only => [:edit, :update, :destroy]
  before_filter :redirect_to_tool, :only => [:new]
  before_filter :authenticate_user!, :only => [:new, :create, :edit, :update]
  respond_to :html, :json, :xml

  # caches_action :index, :cache_path => Proc.new { |controller| controller.params.merge(:logged_in => logged_in? ) }, :expires_in => 2.minutes
  caches_action :show, :cache_path => Proc.new { |controller| controller.params.merge(:logged_in => logged_in?, :claimed => (logged_in? && (current_user.admin? || current_user.claimed_tool?(params[:id])) ? true : false) ) }, :expires_in => 2.minutes

  @@order = { "sites" => "sites_count", 
              "toolname" => "lower_name",
              "bookmarks" => "bookmarks_count",
              "jobs" => "jobs_count",
              "created" => "created_at" }

  @@site_order = { "google" => "google_pagerank", 
                   "alexa" => "coalesce(alexa_global_rank, 100000000)", 
                   "tools" => "tools_count", 
                   "sitename" => "title",
                   "jobs" => "jobs_count"
                 }

  def index
    @search = Sunspot.search(Tool) do
      keywords params[:search] if params[:search]
      
      keywords params[:category], :fields => [:categories] if params[:category]
      order_by(order_field.to_sym, order_direction.to_sym)
      paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 30)
    end
    
    # @tools = Tool.order(build_order).paginate(:page => (params[:page] || 1), :per_page => (params[:per_page] || 25))
    @categories = Category.order(:name).where("tools_count > 0")
    @featured = Tool.featured.limit(5)
    respond_with @search.results
  end
  
  def show
    @tool = Tool.find_by_cached_slug!(params[:id])
    @usings = @tool.usings.joins(:site).includes([:site, :tool]).order(build_site_order).paginate(:page => 1, :per_page => 25)
    @featured = Tool.featured.limit(5)
    respond_with @tool
  rescue ActiveRecord::RecordNotFound
    redirect_to tools_path, :flash => { :error => "Unable to find a tool matching #{params[:id]}" }
  end

  def edit
    respond_with(@tool)
  end

  def update
    if @tool.update_attributes(params[:tool])
      redirect_to @tool
    else
      flash[:error] = "There was a problem updating this tool."
      render :edit
    end    
  end

  # GET /tools.new
  def new
    params[:tool] ||= {}
    url = params[:tool][:url]
    if url
      @link = Link.find_or_create_by_url(url)
      @tool = Tool.new_from_link(@link)
    else
      @tool = Tool.new(params[:tool])
    end
  end
  
  # POST /tools/lookup
  def lookup
    @link = Link.find_or_create_by_url(params[:tool][:url])
    respond_to do |format|
      format.js do
        if @link.nil?
          render :lookup_failed
        elsif @tool = @link.tool
          render :duplicate
        elsif @link.parsed? && (@tool = Tool.new_from_link(@link))
          render :lookup_complete
        elsif @link.unparseable? || @link.unreachable?
          render :lookup_failed
        else
          render :js => "console.log('create in progress');"
        end
      end
    end
  end
  
  def create
    @tool = Tool.create(params[:tool])
    if @tool.new_record?
      @link = Link.find_or_create_by_url(params[:tool][:url])
      flash[:error] = "There was a problem creating this tool."
      respond_to do |format|
        format.html { render :new }
        format.popup { render :new }
      end
    else
      respond_to do |format|
        format.html { redirect_to @tool }
        format.popup { redirect_to tool_path(@tool, :format => :popup) }
      end
    end
  end

  def autocomplete
    tags = Tool.autocomplete(params[:q]).collect do |tool|
      { "name" => "#{tool.name}#{" (#{tool.cached_language[:name]})" if tool.cached_language}", "id" => tool.id.to_s }
    end
    render :json => tags
  end
  
  def destroy
    if @tool.destroy
      flash[:notice] = "Delete successful"
      redirect_to tools_path
    else
      flash[:error] = "There was a problem deleting this tool."
      redirect_to tool_path(@tool)
    end
  end

  def bookmarks
    @tool = Tool.find_by_cached_slug!(params[:id])
    @bookmarks = @tool.bookmarks
    respond_with([@tool, @bookmarks])
  end

  private
  def build_order
    params[:sort] ||= "sites_desc"
    order = params[:sort]
    sort_order = @@order[order.split("_").first] rescue "sites_count"
    direction = order.split("_").last rescue "desc"
    return "#{sort_order} #{direction}"
  end
  
  def order_field
    build_order.split(" ").first
  end

  def order_direction
    build_order.split(" ").last
  end

  def build_site_order
    params[:sort] ||= "alexa_asc"
    order = params[:sort]
    sort_order = @@site_order[order.split("_").first] rescue "alexa_global_rank"
    direction = order.split("_").last rescue "asc"
    return "#{sort_order} #{direction}, sites.title"    
  end  
  
  def load_record
    @tool = Tool.find_by_cached_slug(params[:id])
  end
  
  def redirect_to_tool
    return true unless params[:tool] && params[:tool][:url]
    url = HandyUrl.new(params[:tool][:url])
    tool = Tool.find_by_handy_url(url)
    redirect_to tool_path(tool, :format => params[:format]) if tool
  end
end