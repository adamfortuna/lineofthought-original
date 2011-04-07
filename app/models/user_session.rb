class UserSession
  def initialize(session, cookies)
    @session = session
    @cookies = cookies
  end
  
  def site?(site)
    (@session[:site_ids] || []).include?(site.id)
  end
  
  def using?(using)
    (@session[:using_ids] || []).include?(using.id)
  end
  
  def tool?(tool)
    (@session[:tool_ids] || []).include?(tool.id)
  end
end