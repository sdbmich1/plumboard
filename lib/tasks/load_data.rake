namespace :db do

  task :load_pixi_ids => :environment do
    # set_keys
    set_temp_keys
  end

  task :update_sites => :environment do
    update_sites
  end

  task :update_contactable_type => :environment do
    update_contactable_type
  end

  task :update_pixis => :environment do
    update_pixis
  end
end

def set_keys
  Listing.all.each do |listing|
    process_record listing
  end
end

def set_temp_keys
  TempListing.all.each do |listing|
    process_record listing
  end
end

def process_record listing
  listing.generate_token
  listing.save!
end

def update_pixis
  pixis = Listing.active.where('category_id < ?', 5)
  pixis.map! {|p| p.end_date = Time.now+14.days; p.save}
end

def update_sites
  sites = Site.where("name like '%Beauty%' or name like '%High School%' 
  	or name like '%Hospital' or name like '%Adult%' or name like '%School%'")
  sites.map! { |s| s.status = 'inactive'; s.save }
end

def update_contactable_type
  contacts = Contact.where("contactable_type like '%Organization%'")
  contacts.map! { |s| s.contactable_type = 'Site'; s.save }
end
