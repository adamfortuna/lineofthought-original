class ApplicationController < ActionController::Base
  before_filter :ensure_domain
  protect_from_forgery
  include FastSessions
  
  protected  
  
  def require_admin!
    if !logged_in? || !current_user.admin?
      redirect_to root_path, :error => "Unable to access that page."
    end
  end
  
  # Disable SSL in Development and Test mode
  def ssl_required?
    !["development", "test"].include?(Rails.env)
  end

  def ensure_domain
    if request.env['HTTP_HOST'] != Settings.root_domain
      # HTTP 301 is a "permanent" redirect
      redirect_to (Settings.root_url + request.env['PATH_INFO']), :status => 301
    end
  end
end