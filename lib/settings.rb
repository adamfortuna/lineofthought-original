class Settings < Settingslogic
  source Rails.root.join('config', 'application.yml')
  namespace Rails.env
  load!
end
