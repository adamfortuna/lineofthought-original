class ProfilesController < ApplicationController
  respond_to :html, :json, :xml

  def show
    @user = lookup_user(params[:id])
    respond_with(@user)
  end

  def sites
    @user = lookup_user(params[:id])
    respond_with(@user)
  end

  def bookmarks
    @user = lookup_user(params[:id])
    respond_with(@user)
  end

  def tools
    @user = lookup_user(params[:id])
    respond_with(@user)
  end
  
  private
  def lookup_user(username)
    User.find_by_username(username)
  end
end