namespace :sites do
  desc "Update ranks for all sites that haven't been updated in a month"
  task :update_ranks => :environment do
    Site.find_in_batches(:conditions => ["ranks_updated_at IS NULL OR ranks_updated_at < ?", 1.month.ago]) do |sites|
      sites.each do |site|
        puts "updating ranks on ... #{site.url}"
        site.update_ranks!
      end
    end
  end
  
  desc "Update cached top tools for each site"
  task :update_top_tools => :environment do
    Site.find_in_batches(:conditions => "tools_count > 0") do |sites|
      sites.each do |site|
        puts "updating top_tools on ... #{site.url}"
        site.update_top_tools!
      end
    end
  end
end