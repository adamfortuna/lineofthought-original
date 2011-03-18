class CategoriesController < ApplicationController
  respond_to :html, :json, :xml
  caches_action :show, :cache_path => Proc.new { |controller| controller.params.merge(:logged_in => logged_in? ) }, :expires_in => 15.minutes

  @@order = { "sites" => "sites_count", 
              "toolname" => "tools.name" }
  
  def show
    @category = Category.find_by_cached_slug!(params[:id])
    @tools = @category.tools.order(build_order)
                 .paginate(:page => (params[:page] || 1), :per_page => (params[:page] || 25))
    @categories = Category.order(:name).where("tools_count > 0")
    respond_with [@category, @tools]
  rescue ActiveRecord::RecordNotFound
    redirect_to tools_path, :error => "Unable to find a category matching #{params[:id]}"
  end
  
  private
  def build_order
    params[:sort] ||= "sites_desc"
    order = params[:sort]
    sort_order = @@order[order.split("_").first] rescue "sites_count"
    direction = order.split("_").last rescue "desc"
    return "#{sort_order} #{direction}"
  end
end