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
end