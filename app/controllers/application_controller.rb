class ApplicationController < ActionController::Base
  protect_from_forgery
  # before_filter :beta_user_check
  
  protected
  def beta_user_check
    redirect_to root_path unless session_exists?
  end
  
  def session_exists?
    session["warden.user.user.key"] && session["warden.user.user.key"].first == "User"
  end
end
