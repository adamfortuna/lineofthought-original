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
    # If not on a secure page, make sure the scheme is http
    puts "Server Name: #{request.env['SERVER_NAME']}, Host Name: #{request.env['HTTP_HOST']}, request schema: #{current_handy_url.scheme}"
    if request.env['HTTP_HOST'] == Settings.root_domain_with_port
      puts "required schema: Non-SSL - #{Settings.default_schema}"
      redirect_to (Settings.root_url + request.env['PATH_INFO']), :status => 301 unless current_handy_url.scheme == Settings.default_schema
    # If on a secure page, make sure the scheme is https
    elsif request.env['HTTP_HOST'] == Settings.ssl_root_domain_with_port
      puts "required schema: SSL - #{Settings.ssl_schema}"
      redirect_to (Settings.ssl_root_url + request.env['PATH_INFO']), :status => 301 unless current_handy_url.scheme == Settings.ssl_schema
    # If not on a known host ["www.lineofthought.com", "lineofthought.com"], redirect to lineofthought.com
    else
      puts "required schema: any"
      redirect_to (Settings.root_url + request.env['PATH_INFO']), :status => 301
    end
  end
  
  def current_handy_url
    @url ||= HandyUrl.new(request.env['REQUEST_URI'])
  end
end