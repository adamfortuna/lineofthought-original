class Admin::JobsController < Admin::BaseController
  def index
    @user = current_user
    @delayed_jobs = Delayed::Job.all.paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 25)
  end
end