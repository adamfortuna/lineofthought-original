desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  # if Time.now.hour % 4 == 0 # run every four hours
  # end

  if true || Time.now.hour == 0 # run at midnight
    # Update cached_tools for all sites
    puts "Updating sites..."
    Site.find_each do |site|
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
    
    puts "Attempt to update pagerank and alexa rating"
    Site.where(["ranks_updated_at IS NULL OR ranks_updated_at < ?", 1.month.ago]).each do |site|
      site.update_ranks!
    end
  end
end