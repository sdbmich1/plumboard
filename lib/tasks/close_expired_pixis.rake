# remove old pixis
task :close_expired_pixis => :environment do
  Listing.close_pixis
end