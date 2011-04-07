module FastSessions
  protected
  def self.included(base)
    base.send :helper_method, :logged_in?, :session_exists?, :current_session, :can_edit_site?, :can_add_lines?, :can_edit_using?, :can_destroy_using?
  end
  
  def logged_in?
    session_exists?
  end
  
  def session_exists?
    session["warden.user.user.key"] && session["warden.user.user.key"].first == "User"
  end
  
  def current_session
    @user_session ||= UserSession.new(session, cookies)
  end
  
  def can_edit_site?(site)
    (logged_in? && (current_user.admin? || current_user.can_edit_site?(site))) || current_session.site?(site)
  end
  
  def can_add_lines?(object)
    return true if object.is_a?(Site) && current_session.site?(object) && !object.claimed?
    return true if object.is_a?(Tool) # && current_session.tool?(object) && !object.claimed?
    return logged_in? && current_user.can_add_lines?(object)
  end
  
  def can_edit_using?(using, site = nil)
    site = site || using.site
    return true if current_session.site?(site) && !site.claimed?
    return logged_in? && current_user.can_edit_using?(using)
  end

  def can_destroy_using?(using, site = nil, tool = nil)
    site = site || using.site
    return true if current_session.using?(using) && !site.claimed?
    return logged_in? && current_user.can_destroy_using?(using)
  end
end