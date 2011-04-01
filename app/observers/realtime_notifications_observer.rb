class RealtimeNotificationsObserver < ActiveRecord::Observer
  observe :user, :site, :tool, :using, :bookmark_user
  
  def after_create(record)
    case record
    when User
      send_pusher_notification('signup',
        { :username => record.username, 
          :avatar => record.gravatar_url })
    when Site
      send_pusher_notification('site',
        { :title => record.title, 
          :url => record.url, 
          :description => record.description, 
          :param => record.cached_slug })
    when Tool
      send_pusher_notification('tool',
        { :name => record.name, 
          :url => record.url, 
          :description => record.description,
          :param => record.cached_slug })
    when Using
      send_pusher_notification('using',
        { :site_title => record.site.title, 
          :site_url => record.site.url, 
          :site_param => record.site.cached_slug,
          :tool_name => record.tool.name, 
          :tool_url => record.tool.url,
          :tool_param => record.tool.cached_slug,
          :description => record.description })
    when BookmarkUser
      send_pusher_notification('bookmark',
        { :title => record.title, 
          :url => record.url, 
          :description => record.description,
          :param => record.parent.cached_slug })
    end
  end

  private
  def send_pusher_notification(event, notification)
    begin
      Pusher["stream"].trigger!(event, notification)
    rescue Pusher::Error => e
      raise e
      # (Pusher::AuthenticationError, Pusher::HTTPError, or Pusher::Error)
    end
  end
  handle_asynchronously :send_pusher_notification
end