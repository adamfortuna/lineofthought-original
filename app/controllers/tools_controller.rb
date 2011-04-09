class ToolsController < ApplicationController
  before_filter :redirect_to_tool, :only => [:new]
  before_filter :authenticate_user!, :only => [:new, :create, :edit, :update]
  before_filter :verify_editable!, :only => [:edit, :update]
  before_filter :verify_destroyable!, :only => [:destroy]
  respond_to :html, :json, :xml

  cache_sweeper :tool_sweeper, :only => [:create, :update, :destroy]
  # caches_action :show, :if => Proc.new { |controller| !logged_in? && params[:page].nil?  && params[:per_page].nil? }, :expires_in => 1.hour, :layout => false
  # just the tools#index, and only when not logged in
  caches_action :index, :if => Proc.new { |controller| !logged_in? && params[:sort].nil? && params[:search].nil? && params[:page].nil?  && params[:per_page].nil? && params[:category].nil? }, :expires_in => 1.hour, :layout => false

  def index
   params[:sort] ||= "tools_desc"
   @tools, @hits, loaded_from_solr = Tool.search_by_params(params)
   if !loaded_from_solr && (params[:search] || params[:category])
     params[:search] = nil
     params[:category] = nil
     flash[:error] = "Sorry, search is not available at the moment. Usually this means Solr is down :/ Please try again later."
   end
   @categories = Category.order(:name)
   @featured = Tool.featured.limit(5)
   respond_with(@tools)
 end
  
  def show
    params[:sort] ||= "alexa_asc"
    @tool = find(params[:id])
    @usings = @tool.usings
                   .joins(:site)
                   .includes(:site)
                   .order(Site.sql_order(params[:sort]))
                   .paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 25)
    @featured = Tool.featured.limit(5)
    respond_with ([@tool, @usings])
  rescue ActiveRecord::RecordNotFound
    redirect_to tools_path, :flash => { :error => "Unable to find a tool matching #{params[:id]}" }
  end

  def edit
    @tool = find(params[:id])
    respond_with(@tool)
  end

  def update
    @tool = find(params[:id])
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
      flash[:notice] = "This tool was added to Line of Thought. You can now add some sites that use it, or edit it."
      respond_to do |format|
        format.html { redirect_to @tool }
        format.popup { redirect_to tool_path(@tool, :format => :popup) }
      end
    end
  end

  def autocomplete
    tags = Tool.autocomplete(params[:term]).collect do |tool|
      { "label" => "#{tool.name}#{" (#{tool.cached_language[:name]})" if tool.cached_language}", 
        "value" => tool.id.to_s,
        "desc" => tool.url,
        "icon" => tool.has_favicon? ? tool.full_favicon_url : nil }
    end
    render :json => tags
  end
  
  def destroy
    @tool = find(params[:id])
    if @tool.destroy
      flash[:notice] = "Delete successful"
      redirect_to tools_path
    else
      flash[:error] = "There was a problem deleting this tool."
      redirect_to tool_path(@tool)
    end
  end

  def bookmarks
    @tool = find(params[:id])
    @bookmarks = @tool.bookmarks.order("created_at desc")
                                .paginate(:per_page => params[:per_page] || 20,
                                          :page => params[:page] || 1)
    respond_with([@tool, @bookmarks])
  end

  def autocomplete_example
    
  end

  private  
  def find(cached_slug)
    Tool.find_by_cached_slug!(cached_slug)
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