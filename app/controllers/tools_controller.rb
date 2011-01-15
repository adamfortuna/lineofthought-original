class ToolsController < ApplicationController
  before_filter :load_record, :only => [:show, :edit, :update]
  respond_to :html, :json, :xml

  @@order = { "sites" => "sites_count", 
              "category" => "categories.name", 
              "toolname" => "tools.name"
            }

  @@site_order = { "google" => "google_pagerank", 
                   "alexa" => "alexa_global_rank", 
                   "tools" => "tools_count", 
                   "sitename" => "title"
                 }
  
  def index
    @tools = Tool.all(:include => :category, :order => build_order).paginate(:page => params[:page] || 1, 
                                                      :per_page => params[:page] || 25)
    @categories = Category.all(:order => :name, :conditions => "tools_count > 0")
    respond_with @tools
  end
  
  def show
    @usings = @tool.usings.all(:joins => [:tool, :site],
                               :include => [:tool, :site],
                               :order => build_site_order).paginate(:page => params[:page] || 1, 
                                                                    :per_page => params[:page] || 25)
    respond_with @tool
  end

  def edit
  end

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

  private
  def load_record
    @tool = Tool.find_by_cached_slug(params[:id]) 
  end
  
  def build_order
    params[:sort] ||= "sites_desc"
    order = params[:sort]
    sort_order = @@order[order.split("_").first] rescue "sites_count"
    direction = order.split("_").last rescue "desc"
    return "#{sort_order} #{direction}"
  end
  
  def build_site_order
    params[:sort] ||= "alexa_asc"
    order = params[:sort]
    sort_order = @@site_order[order.split("_").first] rescue "alexa_global_rank"
    direction = order.split("_").last rescue "asc"
    return "#{sort_order} #{direction}"    
  end
end