desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  # if Time.now.hour % 4 == 0 # run every four hours
  # end

  if true || Time.now.hour == 0 # run at midnight
    # Update cached_tools for all sites
    puts "Updating sites..."
    Site.find_each do |site|
      puts "updating site #{site.title}"
      site.update_cached_tools!
    end
    puts "sites updated!"
    
    puts "updating tools..."
    Tool.find_each do |tool|
      tool.update_cached_categories!
      tool.update_bookmarks!
      tool.update_cached_sites!
    end
    puts "tools updated!"
  end
end