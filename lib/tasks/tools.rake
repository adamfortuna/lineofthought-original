namespace :tools do

  desc "Update cached top tools for each tool"
  task :update_top_sites => :environment do
    Tool.find_in_batches(:conditions => "sites_count > 0") do |tools|
      tools.each do |tool|
        puts "updating top_sites on ... #{tool.name}"
        tool.update_top_sites!
      end
    end
  end

  desc "Update cached categories for each tool"
  task :update_cached_categories => :environment do
    Tool.find_in_batches do |tools|
      tools.each do |tool|
        puts "updating cached_categories on ... #{tool.name}"
        tool.update_cached_categories!
      end
    end
  end  
  
  desc "Fill in gaps in site info"
  task :load => :environment do
    Tool.find_in_batches do |tools|
      tools.each do |tool|
        puts "updating cached_categories on ... #{tool.name}"
        begin
          tool.load_by_url
          tool.save
        rescue 
          puts "Unable to load #{tool.name}"
        end
      end
    end
  end  
  
  desc "Load favicons"
  task :load_favicons => :environment do
    Tool.find_in_batches(:conditions => "favicon_url is not null") do |tools|
      tools.each do |tool|
        puts "updating favicons ... #{tool.name}"
        begin
          tool.download_favicon!
        rescue 
          puts "Unable to load #{tool.name}"
        end
      end
    end
  end
  
  desc "reLoad favicons"
  task :reload_favicons => :environment do
    Tool.find_in_batches(:conditions => "favicon_url is not null") do |tools|
      tools.each do |tool|
        puts "updating favicons ... #{tool.name}"
        begin
          tool.download_favicon!
        rescue 
          puts "Unable to load #{tool.name}"
        end
      end
    end
  end
end