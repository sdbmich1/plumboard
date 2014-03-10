namespace :manage_server do

  # resets tables for testing
  task :reset_users => :environment do
    User.destroy_all
  end

  # resets tables for testing
  task :reset_tables => :environment do
    Transaction.destroy_all
    Listing.destroy_all
    TempListing.destroy_all
  end
end

