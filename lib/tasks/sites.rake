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
end