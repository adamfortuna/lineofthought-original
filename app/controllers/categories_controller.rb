class CategoriesController < ApplicationController
  before_filter :load_record, :only => [:edit, :update, :destroy]
  respond_to :html, :json, :xml
  caches_action :show, :cache_path => Proc.new { |controller| controller.params }, :expires_in => 15.minutes

  @@order = { "sites" => "sites_count", 
              "toolname" => "tools.name" }
  
  def index
    @categories = Category.all(:order => :name, :conditions => "tools_count > 0")
    respond_with @categories
  end
  
  def show
    @category = Category.find_by_cached_slug(params[:id]) 
    @tools = @category.tools.order(build_order)
                 .paginate(:page => (params[:page] || 1), :per_page => (params[:page] || 25))
    @categories = Category.order(:name).where("tools_count > 0")
    respond_with [@category, @tools]
  end

  def new
    @category = Category.new
  end
  
  def create
    @category = Category.create(params[:category])
    if @category.new_record?
      flash[:error] = "There was a problem creating this category."
      render :new
    else
      redirect_to @category
    end
  end

  def edit; end

  def update
    if @category.update_attributes(params[:category])
      redirect_to @category
    else
      flash[:error] = "There was a problem updating this category."
      render :edit
    end    
  end

  def destroy
    if @category.destroy
      flash[:notice] = "The category '#{@category.name}' was removed."
      redirect_to categories_path
    else
      flash[:error] = "There was a problem removing the category, please try again."
      redirect_to category_path(@category)
    end
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
    @category = Category.find_by_cached_slug(params[:id])
  end
end