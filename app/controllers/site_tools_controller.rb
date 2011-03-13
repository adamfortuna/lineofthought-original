class SiteToolsController < ApplicationController
  before_filter :load_record, :only => [:manage, :autocomplete]
  respond_to :html, :json, :xml

  @@order = { "sites" => "sites_count", 
              "toolname" => "tools.name",
              "articles" => "tools.articles_count",
              "jobs" => "tools.jobs_count" }

  # GET /sites/:site_id/tools
  def index
    @site = Site.find_by_cached_slug!(params[:site_id]) 
    @usings = @site.usings.includes(:tool).joins(:tool).order(build_order)
    respond_with([@site, @usings])
  rescue ActiveRecord::RecordNotFound
    redirect_to sites_path, :flash => { :error => "Unable to find a site matching #{params[:id]}" }
  end
  
  # GET /sites/:site_id/tools/:id
  def show
    @site = Site.find_by_cached_slug!(params[:site_id]) 
    @tool = Tool.find_by_cached_slug!(params[:id]) 
    @using = @site.usings.where(:tool_id => @tool.id).first
  rescue ActiveRecord::RecordNotFound
    redirect_to sites_path, :flash => { :error => "Unable to find a site matching #{params[:id]}" }
  end

  # GET /sites/:site_id/tools/manage
  def manage
    @usings = @site.usings.all(:include => :tool, :order => "tools.name")
    respond_to do |format|
      format.html
      format.popup
    end
  end
  
  # POST /sites/:site_id/tools
  def create
    respond_to do |format|
      format.js {
        if @using = @site.usings.create(params[:using])
          render
        else
          render :js => "alert('problem');"
        end
      }
    end   
  end
  
  # DELETE /sites/:site_id/tools/:id
  # def destroy
  #   @using = @site.usings.find(params[:using_id])
  #   respond_to do |format|
  #     format.js {
  #       if @using.destroy
  #         render 'destroy.js'
  #       else
  #         render :js => "alert('problem');"
  #       end
  #     }
  #   end
  # end

  # GET /sites/:site_id/tools/autocomplete
  def autocomplete
    tags = Tool.limit(50)
               .order('sites_count DESC')
               .select([:id, :name, :sites_count])
               .where(['tools.name LIKE ?', "#{params[:q]}%"]).collect do |tool|
      { "name" => "#{tool.name} (#{tool.sites_count})", "id" => tool.id.to_s }
    end
    render :json => (tags - @site.tools_hash)
  end


  private
  def load_record
    @site = Site.find_by_cached_slug(params[:site_id])
  end
  
  def build_order
    params[:sort] ||= "sites_desc"
    order = params[:sort]
    sort_order = @@order[order.split("_").first] rescue "sites_count"
    direction = order.split("_").last rescue "desc"
    return "#{sort_order} #{direction}"
  end
end