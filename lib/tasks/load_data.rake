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
  pixis = Listing.active
  pixis.map! {|p| p.end_date = Time.now+30.days; p.job_type_code = 'FT' if p.job?; p.save!}
end

def updateCategoryType
  Category.where(name: ['GIGS', 'JOBS', 'EMPLOYMENT']).update_all(category_type: 'employment')
  Category.where(name: ['EVENT', 'EVENTS', 'HAPPENINGS', 'TICKETS']).update_all(category_type: 'event')
  Category.where(name: ['ANTIQUES', 'AUTOMOTIVE', 'BOATS', 'COLLECTIBLES', 'MOTORCYCLE', 'REAL ESTATE']).update_all(category_type: 'asset')
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
  contacts = Contact.where("contactable_type like '%Organization%'")
  contacts.map! { |s| s.contactable_type = 'Site'; s.save }
end

def update_points
  PixiPoint.all.each {|p| p.value *= 10; p.save}
end

def update_pixi_buyers
  invoices = Invoice.where(status: 'paid')

  invoices.each do |i|
    listing = i.listing
    puts listing.title
    listing.buyer_id = i.buyer_id
    listing.save
  end
end

# load pixi lat/lng based on site location 
def load_pixi_lat_lng
  include LocationManager

  Listing.active.each do |p|
    ll = LocationManager::get_lat_lng_by_loc p.site_name
    if ll
      p.lat, p.lng = ll
      p.save
    end
  end
end
