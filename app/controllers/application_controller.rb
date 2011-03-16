class ApplicationController < ActionController::Base
  protect_from_forgery

  protected  
  def session_exists?
    session["warden.user.user.key"] && session["warden.user.user.key"].first == "User"
  end
end
