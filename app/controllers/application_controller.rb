class ApplicationController < ActionController::Base
  protect_from_forgery
  include FastSessions

  
  protected  
  
  def require_admin!
    if !logged_in? || !current_user.admin?
      redirect_to root_path, :error => "Unable to access that page."
    end
  end
end