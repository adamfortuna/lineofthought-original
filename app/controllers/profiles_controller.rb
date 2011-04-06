class ProfilesController < ApplicationController
  respond_to :html, :json, :xml

  # GET /profile/edit
  def edit
    @user = current_user
    respond_with(@user)
  end

  # PUT /profile
  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to edit_profile_path, :flash => { :notice => "Your profile was updated." }
    else
      render :edit
    end
  end
  
  def show
    @user = lookup_user(params[:id])
    respond_with(@user)
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, :flash => { :error => "Unable to find a profile matching #{params[:id]}" }
  end

  def sites
    @user = lookup_user(params[:id])
    @sites = @user.sites.order(:title).paginate(:per_page => params[:per_page] || 20,
                                                :page => params[:page] || 1)
    respond_with([@user, @sites])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, :flash => { :error => "Unable to find a profile matching #{params[:id]}" }
  end

  def bookmarks
    @user = lookup_user(params[:id])
    @bookmarks = @user.bookmarks.order("created_at desc")
                                .paginate(:per_page => params[:per_page] || 20,
                                          :page => params[:page] || 1)
    respond_with([@user, @bookmarks])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, :flash => { :error => "Unable to find a profile matching #{params[:id]}" }
  end

  def tools
    @user = lookup_user(params[:id])
    @tools = @user.tools.order(:name).paginate(:per_page => params[:per_page] || 20,
                                               :page => params[:page] || 1)
    respond_with([@user, @tools])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, :flash => { :error => "Unable to find a profile matching #{params[:id]}" }
  end
  
  private
  def lookup_user(username)
    User.find_by_username!(username)
  end
end