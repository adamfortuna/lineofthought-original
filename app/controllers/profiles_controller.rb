class ProfilesController < ApplicationController
  respond_to :html, :json, :xml

  def show
    @user = lookup_user(params[:id])
    respond_with(@user)
  end

  def sites
    @user = lookup_user(params[:id])
    @sites = @user.sites.order(:title).paginate(:per_page => params[:per_page] || 20,
                                                :page => params[:page] || 1)
    respond_with([@user, @sites])
  end

  def bookmarks
    @user = lookup_user(params[:id])
    respond_with(@user)
  end

  def tools
    @user = lookup_user(params[:id])
    @tools = @user.tools.order(:name).paginate(:per_page => params[:per_page] || 20,
                                               :page => params[:page] || 1)
    respond_with([@user, @tools])
  end
  
  private
  def lookup_user(username)
    User.find_by_username(username)
  end
end