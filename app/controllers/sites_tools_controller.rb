class SitesToolsController < ApplicationController
  before_filter :load_record, :only => [:create, :edit, :update, :destroy]
  respond_to :html, :json, :xml

  def index
    @tools = @sites.tools.all
    respond_with(@tools)
  end

  def edit; end

  def create
    @using = @site.usings.new(params[:using])
    respond_to do |format|
      format.js {
        if @using.save
          render 'create.js'
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

  private
  def load_record
    @site = Site.find_by_cached_slug(params[:site_id])
  end
end