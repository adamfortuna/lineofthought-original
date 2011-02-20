class ToolsController < ApplicationController
  before_filter :load_record, :only => [:edit, :update, :destroy]
  respond_to :html, :json, :xml
  caches_action :index, :cache_path => Proc.new { |controller| controller.params }, :expires_in => 5.minutes
  caches_action :show, :cache_path => Proc.new { |controller| controller.params }, :expires_in => 5.minutes

  @@order = { "sites" => "sites_count", 
              "toolname" => "tools.name" }

  def index
    # @tools = Tool.order(build_order).includes(:categories, :language)
    #              .paginate(:page => (params[:page] || 1), :per_page => (params[:page] || 25))
    @tools = Tool.order(build_order).paginate(:page => (params[:page] || 1), :per_page => (params[:per_page] || 10))
    @categories = Category.order(:name).where("tools_count > 0")
    respond_with @tools
  end
  
  def show
    @tool = Tool.find_by_cached_slug(params[:id])
    @usings = @tool.usings.joins(:site).includes(:site).order("coalesce(alexa_global_rank, 100000000)").paginate(:page => 1, :per_page => 25)
    params[:sort] = "alexa"
    respond_with @tool
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

  def new
    @tool = Tool.new
  end
  
  def create
    @tool = Tool.create(params[:tool])
    if @tool.new_record?
      flash[:error] = "There was a problem creating this tool."
      render :new
    else
      redirect_to @tool
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

  def articles
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
end