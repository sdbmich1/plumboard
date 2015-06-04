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

  # send expiring pixi notices
  task :send_expiring_pixi_notices, [:arg1] => [:environment] do |t, args|
    a = args[:arg1].to_i
    pixis = Listing.soon_expiring_pixis(a)
    if !pixis.nil?
      pixis.each do |pixi|
        UserMailer.delay.send_expiring_pixi_notice(args.arg1, pixi)
      end
    end
  end
  
  # send expiring draft pixi notices
  task :send_expiring_draft_pixi_notices, [:arg1] => [:environment] do|t, args|
    a = args[:arg1].to_i
    pixis = TempListing.soon_expiring_pixis(a, ['edit', 'new'])
    if !pixis.nil?
      pixis.each do |pixi|
        UserMailer.delay.send_expiring_pixi_notice(args.arg1, pixi)
      end
    end
  end	

  # assign cards to customer
  task :update_balanced_accts => :environment do 
    include BalancedPayment
    User.where(email: 'pixy@testuser.com').find_each do |usr|
      uri = usr.acct_token
      unless uri.blank? 
	puts "Found token #{uri} for #{usr.name} ..."
	
	customer = Balanced::Customer.find uri rescue nil
	unless customer
	  puts "Adding customer account for #{usr.name} ..."
	  customer = Balanced::Customer.new(name: usr.name, email: usr.email).save 

	  # reset uri
	  puts "Resetting uri for #{usr.name} ..."
	  uri = usr.acct_token = customer.uri
	  usr.save!
	end

        usr.card_accounts.find_each do |acct|
	  puts "Assigning card for #{usr.name} ..."
          result = Payment::assign_card uri, acct.token # rescue nil
	  puts "Assigned card #{acct.token} to #{usr.name} token #{uri}" # unless result
	end
      end
    end
  end	

  task :send_invoiceless_pixi_notices => :environment do
    listings = Listing.invoiceless_pixis
    unless listings.blank?
      listings.each do |listing|
        UserMailer.delay.send_invoiceless_pixi_notice listing
      end
    end
  end

  task :send_unpaid_old_invoice_notices => :environment do
    invoices = Invoice.unpaid_old_invoices
    unless invoices.blank?
      invoices.each do |invoice|
        UserMailer.delay.send_unpaid_old_invoice_notice invoice
      end
    end
  end

  task :cleanup_guests => :environment do
    User.where(guest: :true).where("created_at < ?", 1.week.ago).destroy_all
  end

  task :reprocess_listing_images => :environment do
    Listing.active.find_each do |pixi|
      pixi.pictures.each do |pic|
        %w(preview medium large).each do |style|
          pic.photo.reprocess! style.to_sym
	end
      end
    end
  end

  task :reprocess_user_images => :environment do
    User.active.find_each do |user|
      user.pictures.each do |pic|
        %w(tiny small thumb medium cover).each do |style|
          pic.photo.reprocess!(style.to_sym)
	end
      end
    end
  end

  task :load_news_feeds => :environment do
    LoadNewsFeed.read_feeds
  end

  task :run_upgrade_tasks => :environment do
    Rake::Task[:import_travel_modes].execute
    Rake::Task[:load_feeds].execute
    Rake::Task[:load_fulfillment_types].execute
    Rake::Task[db:update_cat_types].execute
    Rake::Task[db:load_user_urls].execute
    Rake::Task[db:load_user_status].execute
    Rake::Task[db:reload_pixi_posts].execute
    Rake::Task[db:load_active_listings_counter].execute
    Rake::Task[db:reload_user_types].execute
    Rake::Task[manage_server:reprocess_user_images].execute
    Rake::Task[manage_server:reprocess_listing_images].execute
  end
end
