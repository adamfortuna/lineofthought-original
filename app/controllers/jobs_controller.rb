class JobsController < ApplicationController
  before_filter :load_record, :only => [:edit, :update, :destroy]
  respond_to :html, :json, :xml

  def index
    @jobs = Job.visibe.all(:order => :title)
    respond_with @categories
  end
  
  def show
    respond_with @job
  end

  def new
    @job = Job.new
  end
  
  def create
    @job = job.create(params[:job])
    if @job.new_record?
      flash[:error] = "There was a problem creating this job."
      render :new
    else
      redirect_to @job
    end
  end

  def edit; end

  def update
    if @job.update_attributes(params[:job])
      redirect_to @job
    else
      flash[:error] = "There was a problem updating this job."
      render :edit
    end    
  end

  def deactivate
    if @job.deactivate!
      flash[:notice] = "The job '#{@job.title}' was deactivated."
      redirect_to jobs_path
    else
      flash[:error] = "There was a problem deactivating this job, please try again."
      redirect_to @job
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