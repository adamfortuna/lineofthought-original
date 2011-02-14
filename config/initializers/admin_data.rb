AdminData.config do |config|
  config.is_allowed_to_view = lambda {|controller| return true if controller.send('session_exists?') }
  config.is_allowed_to_update = lambda {|controller| return true if controller.send('session_exists?') }
end