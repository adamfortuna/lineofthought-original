class ApplicationController < ActionController::Base
  protect_from_forgery
  include FastSessions
  include ::SslRequirement
  before_filter :ensure_domain
  # ssl_allowed :all

  protected  
  
  def require_admin!
    if !logged_in? || !current_user.admin?
      redirect_to root_path, :error => "Unable to access that page."
    end
  end
  
  # Disable SSL in Development and Test mode
  def ssl_required?
    return false if ["development", "test"].include?(Rails.env)
    super
  end
  
  def ensure_domain
    return true unless Rails.env == "production"
    # redirect if not on lineofthought
    schema = request.env['HTTP_X_FORWARDED_PROTO'] || "http"    
    if request.env['HTTP_HOST'] == Settings.root_domain_with_port
      redirect_to (Settings.root_url + request.env['PATH_INFO']), :status => 301 if schema != Settings.default_schema
    # If on a secure page, make sure the scheme is https
    elsif request.env['HTTP_HOST'] == Settings.ssl_root_domain_with_port
      redirect_to (Settings.ssl_root_url + request.env['PATH_INFO']), :status => 301 if schema != Settings.ssl_schema
    # If not on a known host ["www.lineofthought.com", "lineofthought.com"], redirect to lineofthought.com
    else
      redirect_to (Settings.root_url + request.env['PATH_INFO']), :status => 301
    end
  end
end