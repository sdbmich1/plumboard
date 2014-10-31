namespace :manage_server do

  # resets tables for testing
  task :reset_users => :environment do
    users = User.where "email not like '%pixiboard.com'"
    users.each do |usr|
      puts "Deleting user #{usr.name}"
      usr.destroy
    end
  end

  # resets tables for testing
  task :reset_tables => :environment do
    Transaction.destroy_all
    Listing.destroy_all
    TempListing.destroy_all
    BankAccount.destroy_all
    CardAccount.destroy_all
    Invoice.destroy_all
    PixiPost.destroy_all
  end

  # remove old pixis
  task :close_expired_pixis => :environment do
    Listing.close_pixis
  end

  # pick fb sweepstakes winner
  task :pick_sweepstakes_winner => :environment do
    entrants = User.where(fb_user: true).order("RAND()")
    puts "The winner is #{entrants.first.name}. Email: #{entrants.first.email}"
  end

  # pick drawing winner
  task :pick_drawing_winner => :environment do
    val = ['abp', 'dr', 'fr', 'bpx', 'spx', 'ppx']
    entrants = UserPixiPoint.where(code: val).where("created_at >= ? AND created_at < ?", '2014-09-02'.to_date, '2014-10-15'.to_date).order("RAND()")
    puts "The winner is #{entrants.first.user.name}. Email: #{entrants.first.user.email}"
  end

end

