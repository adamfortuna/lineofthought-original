module FastSessions
  protected
  def self.included(base)
    base.send :helper_method, :logged_in?, :session_exists?
  end
  
  def logged_in?
    session_exists?
  end
  
  def session_exists?
    session["warden.user.user.key"] && session["warden.user.user.key"].first == "User"
  end
end