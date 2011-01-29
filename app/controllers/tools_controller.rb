class ToolsController < ApplicationController
  before_filter :load_record, :only => [:edit, :update]
  respond_to :html, :json, :xml
  caches_action :index, :cache_path => Proc.new { |controller| controller.params }, :expires_in => 15.minutes
  caches_action :show, :cache_path => Proc.new { |controller| controller.params }, :expires_in => 15.minutes

  @@order = { "sites" => "sites_count", 
              "toolname" => "tools.name" }

  def index
    @tools = Tool.order(build_order).includes(:categories)
                 .paginate(:page => (params[:page] || 1), :per_page => (params[:page] || 25))
    @categories = Category.order(:name).where("tools_count > 0")
    respond_with @tools
  end
  
  def show
    @tool = Tool.find_by_cached_slug(params[:id])
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
    tags = Tool.all(:limit => 50, :order => 'sites_count DESC', :select => [:id, :name, :sites_count],
                    :conditions => ['tools.name LIKE ?', "#{params[:q]}%"]).collect do |tool|
      { :name => "#{tool.name} (#{tool.sites_count})", :id => tool.name.to_s }
    end
    render :json => tags
  end

  def lookup
    
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