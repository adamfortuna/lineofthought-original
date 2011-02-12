class SitesToolsController < ApplicationController
  before_filter :load_record, :only => [:create, :edit, :update, :destroy, :autocomplete]
  respond_to :html, :json, :xml

  def index
    @tools = @sites.tools.all
    respond_with(@tools)
  end

  def edit
    @usings = @site.usings.all(:include => :tool, :order => "tools.name")
  end

  def create
    @using = @site.usings.new(params[:using])
    respond_to do |format|
      format.js {
        if @using.save
          render
        else
          render :js => "alert('problem');"
        end
      }
    end   
  end

  def destroy
    @using = @site.usings.find(params[:using_id])
    respond_to do |format|
      format.js {
        if @using.destroy
          render 'destroy.js'
        else
          render :js => "alert('problem');"
        end
      }
    end
  end

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
end