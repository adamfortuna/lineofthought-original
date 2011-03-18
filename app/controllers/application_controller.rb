class ApplicationController < ActionController::Base
  protect_from_forgery
  include FastSessions

  
  protected  
  
  def require_admin!
    if !logged_in? || !current_user.admin?
      redirect_to root_path, :error => "Unable to access that page."
    end
  end
  
  def render_optional_error_file(status_code)
    status = interpret_status(status_code)
    code   = status[0, 3] # "404 Not Found"
    
    respond_to do |wants|
      wants.html { render :template => "errors/#{code}", :status => status }
      wants.all { head status }
    end
  end
end
