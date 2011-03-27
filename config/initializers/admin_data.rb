AdminData.config do |config|
  config.drop_down_for_associations = false
  config.is_allowed_to_view = lambda {|controller| return true if controller.send('session_exists?') }
  config.is_allowed_to_update = lambda {|controller| return true if controller.send('session_exists?') }
  config.find_conditions =  {
    'Tool' => lambda {|params| {:conditions =>   ["permanent_name = ?", params[:id] ] } },
    'Site' => lambda {|params| {:conditions =>   ["permanent_name = ?", params[:id] ] } },
    'Bookmark' => lambda {|params| {:conditions =>   ["permanent_name = ?", params[:id] ] } },
    'Category' => lambda {|params| {:conditions =>   ["permanent_name = ?", params[:id] ] } }
    
  }
  
end