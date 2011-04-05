class AccountsController < ApplicationController
  before_filter :authenticate_user!, :only => [:create]
  respond_to :html

  # GET /profile/edit
  def edit
    @user = current_user
    respond_with(@user)
  end

  # PUT /profile
  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to edit_account_path, :flash => { :notice => "Your profile was updated." }
    else
      render :edit
    end
  end
end