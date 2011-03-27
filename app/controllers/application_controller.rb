class ApplicationController < ActionController::Base
  before_filter :ensure_domain
  protect_from_forgery
  include FastSessions
  include SslRequirement
  
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
    if (request.env['HTTP_HOST'] != Settings.root_domain) && (request.env['HTTP_HOST'] != Settings.ssl_root_domain)
      url = HandyUrl.new(request.env['HTTP_HOST'])
      if url.host == Settings.ssl_root_domain
        redirect_to (Settings.ssl_root_url + request.env['PATH_INFO']), :status => 301 unless url.scheme == "https"
      elsif url.host == Settings.root_domain
        redirect_to (Settings.root_url + request.env['PATH_INFO']), :status => 301 unless url.scheme == "http"
      else
        redirect_to (Settings.root_url + request.env['PATH_INFO']), :status => 301
      end
    end
  end
end