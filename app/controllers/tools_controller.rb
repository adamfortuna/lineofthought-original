class ToolsController < ApplicationController
  before_filter :load_record, :only => [:edit, :update, :destroy]
  before_filter :redirect_to_tool, :only => [:new]
  respond_to :html, :json, :xml

  @@order = { "sites" => "sites_count", 
              "toolname" => "tools.name",
              "articles" => "tools.articles_count",
              "jobs" => "tools.jobs_count" }

  def index
    # @tools = Tool.order(build_order).includes(:categories, :language)
    #              .paginate(:page => (params[:page] || 1), :per_page => (params[:page] || 25))
    @tools = Tool.order(build_order).paginate(:page => (params[:page] || 1), :per_page => (params[:per_page] || 10))
    @categories = Category.order(:name).where("tools_count > 0")
    @featured = Tool.featured.limit(5)
    respond_with @tools
  end
  
  def show
    @tool = Tool.find_by_cached_slug!(params[:id])
    @usings = @tool.usings.joins(:site).includes(:site).order("coalesce(alexa_global_rank, 100000000)").paginate(:page => 1, :per_page => 25)
    @featured = Tool.featured.limit(5)
    params[:sort] = "alexa"
    respond_with @tool
  rescue ActiveRecord::RecordNotFound
    redirect_to tools_path, :flash => { :error => "Unable to find a tool matching #{params[:id]}" }
  end

  def edit; end

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
    link = Link.find_or_create_by_url(params[:tool][:url])
    respond_to do |format|
      format.js do
        if link.source
          render :js => "alert('already exists');"
        elsif link.parsed?
          @tool = Tool.new_from_link(link)
          render :lookup_complete
        else
          render :js => ""
          # no response, lookup in progress
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
    tags = Tool.limit(50)
               .order('sites_count DESC')
               .select([:id, :name, :sites_count])
               .where(['tools.name LIKE ?', "#{params[:q]}%"]).collect do |tool|
      { "name" => "#{tool.name} (#{tool.sites_count})", "id" => tool.id.to_s }
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
    @tool = Tool.find_by_cached_slug(params[:id])
    @articles = @tool.articles.order("created_at desc")
                     .paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 15)
  end

  private
  def build_order
    params[:sort] ||= "sites_desc"
    order = params[:sort]
    sort_order = @@order[order.split("_").first] rescue "sites_count"
    direction = order.split("_").last rescue "desc"
    return "#{sort_order} #{direction}"
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