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
    schema = request.env['HTTP_X_FORWARDED_PROTO'] || "http"
    # If not on a secure page, make sure the scheme is http
    puts "Server Name: #{request.env['SERVER_NAME']}, Host Name: #{request.env['HTTP_HOST']}"
    puts "Current request: #{request.env['REQUEST_URI']}, schema: #{schema}"
    # puts "\n\nEnv: #{request.env}\n\n"
    
    if request.env['HTTP_HOST'] == Settings.root_domain_with_port
      puts "required schema: Non-SSL - should be #{Settings.default_schema} / is #{schema}"
      redirect_to (Settings.root_url + request.env['PATH_INFO']), :status => 301 if schema != Settings.default_schema
    # If on a secure page, make sure the scheme is https
    elsif request.env['HTTP_HOST'] == Settings.ssl_root_domain_with_port
      puts "required schema: SSL - should be #{Settings.ssl_schema} / is #{schema}"
      if schema != Settings.ssl_schema
        puts "schema class: "
        redirect_to (Settings.ssl_root_url + request.env['PATH_INFO']), :status => 301
      end
    # If not on a known host ["www.lineofthought.com", "lineofthought.com"], redirect to lineofthought.com
    else
      puts "required schema: any"
      redirect_to (Settings.root_url + request.env['PATH_INFO']), :status => 301
    end
  end
end