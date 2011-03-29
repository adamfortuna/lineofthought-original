class ToolsController < ApplicationController
  before_filter :load_record, :only => [:edit, :update, :destroy]
  before_filter :redirect_to_tool, :only => [:new]
  before_filter :authenticate_user!, :only => [:new, :create, :edit, :update]
  before_filter :verify_editable!, :only => [:edit, :update]
  before_filter :verify_destroyable!, :only => [:destroy]
  respond_to :html, :json, :xml
  cache_sweeper :site_sweeper, :only => [:create, :update, :destroy]

  # caches_action :index, :cache_path => Proc.new { |controller| controller.params.merge(:logged_in => logged_in? ) }, :expires_in => 2.minutes
  caches_action :show, :cache_path => Proc.new { |controller| controller.params.merge(:logged_in => logged_in?, :claimed => (logged_in? && (current_user.admin? || current_user.claimed_tool?(params[:id])) ? true : false) ) }, :expires_in => 12.hours

  @@site_order = { "google" => "google_pagerank", 
                   "alexa" => "coalesce(alexa_global_rank, 100000000)", 
                   "tools" => "tools_count", 
                   "sitename" => "title",
                   "jobs" => "jobs_count"
                 }

  def index
   params[:sort] ||= "tools_desc"
   @tools, @hits, loaded_from_solr = Tool.search_by_params(params)
   if !loaded_from_solr && (params[:search] || params[:category])
     params[:search] = nil
     params[:category] = nil
     flash[:error] = "Sorry, search is not available at the moment. Usually this means Solr is down :/ Please try again later."
   end
   @categories = Category.order(:name).where("tools_count > 0")
   @featured = Tool.featured.limit(5)
   respond_with(@tools)
 end
  
  def show
    params[:sort] ||= "alexa_asc"
    @tool = Tool.find_by_cached_slug!(params[:id])
    @usings = @tool.usings.joins(:site).includes(:site).order(Site.sql_order(params[:sort])).paginate(:page => 1, :per_page => 25)
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
    @tool = Tool.create(params[:tool].merge(:claimer => current_user))
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
  def load_record
    @tool = Tool.find_by_cached_slug(params[:id])
  end
  
  def redirect_to_tool
    return true unless params[:tool] && params[:tool][:url]
    url = HandyUrl.new(params[:tool][:url])
    tool = Tool.find_by_handy_url(url)
    redirect_to tool_path(tool, :format => params[:format]) if tool
  end
  
  def verify_editable!
    return true if current_user.can_edit_tool?(@tool)
    redirect_to tool_path(@tool, :format => params[:format]), :flash => { :error => "You don't have access to edit this tool." }
    return false
  end
  
  def verify_destroyable!
    return true if current_user.can_destroy_tool?(@tool)
    redirect_to tool_path(@tool, :format => params[:format]), :flash => { :error => "You don't have access to delete this tool." }
    return false
  end
end