class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :beta_user_check
  
  protected
  def beta_user_check
    redirect_to root_path unless user_signed_in?
  end
end
