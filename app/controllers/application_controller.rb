class ApplicationController < ActionController::Base
  protect_from_forgery

  protected  
  def session_exists?
    session["warden.user.user.key"] && session["warden.user.user.key"].first == "User"
  end
  
  def require_admin!
    if !user_signed_in? || !current_user.admin?
      redirect_to root_path, :error => "Unable to access that page."
    end
  end
end
