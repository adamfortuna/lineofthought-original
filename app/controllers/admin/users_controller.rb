class Admin::UsersController < Admin::BaseController
  def index
    @user = current_user
    @users = User.all.paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 25)
  end
end