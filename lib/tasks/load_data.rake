namespace :db do

  # set_keys
  task :load_pixi_ids => :environment do
    set_temp_keys
  end

  task :update_cat_types => :environment do
    updateCategoryType
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

  task :reset_points => :environment do
    update_points
  end

  task :set_pixi_buyers => :environment do
    update_pixi_buyers
  end

  # used to load user roles
  task :load_roles, [:role] => [:environment] do |t, args|
    Role.create!(:name => args.role)
  end

  task :load_lat_lng, [:site] => [:environment] do |t, args|
    load_contact_lat_lng args.site
  end
  
  task :fix_txn_details_price => :environment do
    update_txn_detail_price
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
  pixis = Listing.where(status: 'active').where(category_id: Category.where("category_type_code != 'event'")).update_all(end_date: Time.now+90.days)
  # pixis.map! {|p| p.end_date = Time.now+30.days unless p.event?; p.job_type_code = 'FT' if p.job?; p.save!}
end

def updateCategoryType
  Category.where(name: ['GIGS', 'JOBS', 'EMPLOYMENT']).update_all(category_type_code: 'employment')
  Category.where(name: ['EVENT', 'EVENTS', 'HAPPENINGS', 'TICKETS']).update_all(category_type_code: 'event')
  Category.where(name: ['ANTIQUES', 'COLLECTIBLES', 'REAL ESTATE']).update_all(category_type_code: 'asset')
  Category.where(name: ['AUTOMOTIVE', 'BOATS', 'MOTORCYCLE']).update_all(category_type_code: 'vehicle')
end

def update_sites
  %W(Barber Center Dental Dentistry Medical Cosmetology Group Vocational Residency Internship Hair Seminary Foundation Bais Professional Language
    Maintenance Learning Health Career Hospital Beauty School Adult Associated Family Church God Animal Training System Clinic Counseling Associate
    Job Aveda Program Healing Acupuncture Message Driving Council Ministries Village Academia Aesthetic Ultrasound Xenon Defense Yeshiva Institucion
    Oneida Medicine Roy BOCES Salon Service Reporting Planning Consulting Therapy Centro Bureau Home Childcare Diving Funeral Skills Pivot Irene
    Recording Massage Automotive Esthetic Study ROP District Guy Universidad UPR CET Flight Division Test Jerusalem SABER Corporation Skin House Plus
    Studies Quest Liceo Diesel Holistic NASCAR NCME ABC Video Nail Detective Solution Fast Train Education Mortuary Baking Theater Partners Society
    Corporate LLC Bellus AIMS Firecamp Federal Tribeca Caribbean Union Torah Travel Creative Cathedral International Desert Fila Montessori Fiber
    Film Radio Laboratory Ames Repair Welding Management Maternidad IMEDIA Police Hypnosis Motivation Hot esprit Notary Midwifery Loraine Association
    ROC Anesthesia Ohr Ballet Symphony Profession OISE Professor AGE Proteus Applied Rolf Children Jeweler Cactus Chubb Collective Coiffure 
    Trend Retirement Joel Motorcycle Waynesville AMS Learnet Kade Mandalyn Digital Headline Interior Social Dale Fairview PSC Research
    Planned Trade global Colegio Labs Tutor Escuela Employment Care Aviation Puerto Instituto Surgical Helicopter Make-up Marketing Company Chaplain
    ZMS ORT Mildred Cultural Scool Beis Paralegal Cosmetic Religion Somatic Inovatech Hospice Height Golf Firenze Dietetic Theatre Limit).each do |loc|
    
    sites = Site.where("status = 'active' and name like ?", '%' + loc + '%').update_all(status: 'inactive')
  end
end

def update_contactable_type
  contacts = Contact.where("contactable_type like '%Organization%'").update_all(contactable_type = 'Site')
  # contacts.map! { |s| s.contactable_type = 'Site'; s.save }
end

def update_points
  # PixiPoint.find_each {|p| p.value *= 10; p.save}
  PixiPoint.update_all("value=value*10")
end

def update_pixi_buyers
  Invoice.where(status: 'paid').find_each do |i|
    listing = i.listing
    puts listing.title
    listing.buyer_id = i.buyer_id
    listing.save
  end
end

# load pixi lat/lng based on site location 
def load_pixi_lat_lng
  include LocationManager

  Listing.active.find_each do |p|
    ll = LocationManager::get_lat_lng_by_loc p.site_name
    if ll
      p.lat, p.lng = ll
      p.save
    end
  end
end

def load_contact_lat_lng loc
  include LocationManager
  loc = loc + '%'

  Site.where("name like ?", loc).find_each do |p|
    ll = LocationManager::get_lat_lng_by_loc p.name
    p.contacts.find_each do |c|
      if ll
        puts "lat, lng: ", ll
        c.lat, c.lng = ll
        c.save
      end
    end
  end
end

# update price for txn details to correct coding error
def update_txn_detail_price
  Transaction.find_each do |txn|
    # get price
    if txn.get_invoice
      price = txn.get_invoice.price

      # load txn details
      td = txn.transaction_details.first

      # set price
      unless price.blank?
        td.price = price
        td.save
      end
    end
  end
end
