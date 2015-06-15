require 'csv'

desc "Import data from csv file"
task :import_sites => :environment do

  CSV.foreach(Rails.root.join('db', 'Accreditation_2011_12.csv'), :headers => true) do |row|
    
   attrs = {
      		:institution_id    => row[0].to_i,
	      	:name              => row[1],
          :status		   => 'active',
          :org_type	   => 'school'
      }

    # filter specialty schools
    spec_site = %W(Barber Center Dental Dentistry Medical Cosmetology Group Vocational Residency Internship Hair Seminary Foundation 
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
    ZMS ORT Mildred Cultural Scool Beis Paralegal Cosmetic Religion Somatic Inovatech Hospice Height Golf Firenze Dietetic 
    Bais Professional Language Theatre Limit).detect { |x| x =~ /^.*\b(#{row[1]})\b.*$/i }
    
    # skip record if specialty school
    next if spec_site

    # add site
    unless site = Site.where(:name => row[1]).first || spec_site
      new_site = Site.new(attrs)

      # set location/contact attributes
      loc_attrs = { 
        :address         => row[2],
	:city            => row[3],
        :state           => row[4],
        :zip             => row[5],
        :work_phone	 => row[6],
        :website	 => row[9]
		}

      # add contact info for site
      new_site.contacts.build(loc_attrs)

      # save site
      if !new_site.blank? && new_site.save 
        puts "Saved site #{attrs.inspect}"
      else
        puts "Error: #{new_site.errors.full_messages.first}"
      end
    end

    # set prev id
    prev_id = row[0]
  end
end

# loads bay area city data
task :load_bay_area_cities => :environment do
  CSV.foreach(Rails.root.join('db', 'bay_area_cities_082713.csv'), :headers => true) do |row|
    
    attrs = {
      :name       => row[0],
      :status     => 'active',
      :org_type	   => 'city'
    }

    # add site
    unless site = Site.where(:name => row[0]).first
      new_site = Site.new(attrs)

      # set location/contact attributes
      loc_attrs = { 
        :city      => row[0],
        :county		 => row[1],
        :state           => 'CA'
      }

      # add contact info for site
      new_site.contacts.build(loc_attrs)

      # save site
      if new_site.save 
        puts "Saved site #{attrs.inspect}"
      else
        puts new_site.errors
      end
    end
  end
end

# loads SF neighborhood data
task :load_sf_neighborhoods => :environment do

   CSV.foreach(Rails.root.join('db', 'sf_neighborhoods_082713.csv'), :headers => true) do |row|
    
   # get area name
   area = row[0].split(' ', 2)[1]

   # set site attributes
   attrs = {
	  :name        => ['San Francisco', area].join(' - '),
		:status		   => 'active',
		:org_type	   => 'area'
      }

    # add site
    unless site = Site.where(:name => row[0]).first
      new_site = Site.new(attrs)

      # set location/contact attributes
      loc_attrs = { 
	     	:address         => area,
	     	:city            => 'San Francisco',
		    :county		 => 'San Francisco',
        :state           => 'CA'
		}

      # add contact info for site
      new_site.contacts.build(loc_attrs)

      # save site
      if new_site.save 
        puts "Saved site #{attrs.inspect}"
      else
        puts "Error: #{new_site.errors.full_messages.first}"
      end
    end
  end
end

# load zip codes for pixi post service areas
task :load_zip_codes => :environment do
  PixiPostZip.delete_all
  CSV.foreach(Rails.root.join('db', 'ZipCodes_2014_03_11.csv'), :headers => true) do |row|
    attrs = {
	      	:zip               => row[0],
      		:city	             => row[1],
      		:state	           => row[2],
          :status		   => 'active'
    }

    # create zip
    new_zip = PixiPostZip.new(attrs)

    # save zip
    if new_zip.save 
      puts "Saved zip #{attrs.inspect}"
    else
      puts new_zip.errors
    end
  end
end



# loads neighborhoods of top 50 cities in US
task :load_neighborhoods => :environment do

   CSV.foreach(Rails.root.join('db', 'DMA_50_neighborhoods_transposed.csv'), :headers => false) do |row|
   
      # converting the row to an array by splitting ','
      row_array = row.split(',');
      

      # setting the name of the city, state and county
      city   = row[0]
      state  = row[1] 
      county = row[2]
      
      # iterating through the elements of the neighborhoods and setting them to area 
      for element in row[3..row.length]    
          # Testing code
          #puts "Inside the for loop"
          
          area = element
      
          # setting site attributes
          attrs = {
            :name        => [city, area].join(' - '),
            :status      => 'active',
            :org_type    => 'area'
          }
      
          # setting location/contact attributes
          loc_attrs = { 
            :address  => area,
            :city     => city,
            :county   => county,
            :state    => state
          }
          
          # add site
          unless site = Site.where(:name => row[0]).first
            new_site = Site.new(attrs)
      
          # add contact info for site
          new_site.contacts.build(loc_attrs)
      
          # save site
          if new_site.save 
            puts "Saved site #{attrs.inspect}"
          else
            puts new_site.errors
          end
      end
    end
  end
end
  
# method used by tasks to load cities
def load_cities(row)

  # setting the name of the city, state and county
    city   = row[0]
    state  = row[1]
    county = row[2]

    attrs = {
        :name        => city,
        :status      => 'active',
        :org_type    => 'city'
    }
    # add site
    unless site = Site.where(:name => city).first
      new_site = Site.new(attrs)

      # setting location/contact attributes
      loc_attrs = {
          :city     => city,
          :county   => county,
          :state    => state
      }

      # add contact info for site
      new_site.contacts.build(loc_attrs)

      # save site
      if new_site.save
        puts "Saved site #{attrs.inspect}"
      else
        puts new_site.errors
      end
  end
end

# loads top 50 cities in US
task :load_top_50_cities => :environment do
  CSV.foreach(Rails.root.join('db', 'DMA_50_neighborhoods_transposed.csv'), :headers => false) do |row|

    # converting the row to an array by splitting ','
    row_array = row.split(',');
    load_cities(row_array)
  end
end

#loads suburbs of top 50 regions
task :load_region_suburbs => :environment do
  CSV.foreach(Rails.root.join('db', 'DMA_50_suburbs.csv'), :headers => true) do |row|
    load_cities(row)
  end
end


task :load_categories => :environment do

  CSV.foreach(Rails.root.join('db', 'category_data_020613.csv'), :headers => true) do |row|

    attrs = {
	  :name              => row[0].titleize,
      	  :category_type_code     => row[1],
          :status		   => 'active'
    }

    # find or add category
    new_category = Category.find_or_initialize_by_name(attrs)

    # add photo
    if new_category.pictures.size == 0
      new_category.pictures.map { |pic| new_category.pictures.delete(pic) }
    end

    picture = new_category.pictures.build(:photo => File.new("#{Rails.root}" + row[2]), :dup_flg => true)

    # save category
    if new_category.save 
      puts "Saved category #{attrs.inspect}"
    else
      puts "Error: #{new_category.errors.full_messages.first}"
    end
  end
end


task :update_categories => :environment do

  CSV.foreach(Rails.root.join('db', 'category_data_042214.csv'), :headers => true) do |row|

    attrs = {:name             => row[1].titleize,
             :category_type_code    => row[2],
             :status           => row[3],
             :pixi_type        => row[4]}

    attrs2 = {:original_name => row[6]}

    #original_name is the original name of the category created by the load_categories task,
    #if it exists. If the category name doesn't exist, original_name is nil. 

    #update category
    updated_category = Category.find(:first, :conditions => ["name = ?", attrs2[:original_name]])
    if not updated_category
      updated_category = Category.find_or_initialize_by_name(attrs)
    else
      updated_category.update_attributes!(attrs)
    end

    #add photo
    while updated_category.pictures.size > 0
      updated_category.pictures.map { |pic| updated_category.pictures.delete(pic) }
    end

    picture = updated_category.pictures.build(:photo => File.new("#{Rails.root}" + row[5]), :dup_flg => true)

    #save category
    if updated_category.save
      puts "Saved category #{attrs.inspect}"
    else
      puts "Error: #{updated_category.errors.full_messages.first}"
    end
  end
end

task :update_category_pictures => :environment do
  CSV.foreach(Rails.root.join('db', 'category_data_042214.csv'), :headers => true) do |row|
    attrs = {:name             => row[1].titleize}

    #find category
    updated_category = Category.find(:first, :conditions => ["name = ?", attrs[:name]])

    #add photo
    while updated_category.pictures.size > 0
      updated_category.pictures.map { |pic| updated_category.pictures.delete(pic) }
    end

    picture = updated_category.pictures.build
    picture.photo = File.new("#{Rails.root}" + row[5]) if picture

    #save category
    if updated_category.save
      puts "Saved category #{attrs.inspect}"
    else
      puts updated_category.errors
    end
  end
end

task :update_region_pictures => :environment do
  CSV.foreach(Rails.root.join('db', 'region_data_052414.csv'), :headers => true) do |row|
    attrs = {:name             => row[0].titleize}

    #find site
    updated_site = Site.find(:first, :conditions => ["name = ?", attrs[:name]])

    #add photo
    while updated_site.pictures.size > 0
      updated_site.pictures.map { |pic| updated_site.pictures.delete(pic) }
    end

    picture = updated_site.pictures.build
    picture.photo = File.new("#{Rails.root}" + row[3]) if picture

    #save site
    if updated_site.save
      puts "Saved site #{attrs.inspect}"
    else
      puts updated_site.errors
    end
  end
end

task :import_point_system => :environment do

  PixiPoint.delete_all
  CSV.foreach(Rails.root.join('db', 'Pixiboard_Point_System_042613.csv'), :headers => true) do |row|

    attrs = {
	      	:value             => row[0],
      		:action_name       => row[1],
          :category_name	   => row[2],
          :code	   	   => row[3]
    }

    # add pixi_point
    new_pixi_point = PixiPoint.new(attrs)

    # save pixi_point
    if new_pixi_point.save 
      puts "Saved pixi_point #{attrs.inspect}"
    else
      puts new_pixi_point.errors
    end
  end
end

task :import_job_type => :environment do

  JobType.delete_all
  CSV.foreach(Rails.root.join('db', 'JobType_020614.csv'), :headers => true) do |row|

    attrs = {
          :code	   => row[0],
      		:job_name  => row[1],
          :status	   => 'active'
    }

    # add job_type
    new_job_type = JobType.new(attrs)

    # save job_type
    if new_job_type.save 
      puts "Saved job_type #{attrs.inspect}"
    else
      puts new_job_type.errors
    end
  end
end

task :import_inquiry_type => :environment do

  InquiryType.delete_all
  CSV.foreach(Rails.root.join('db', 'InquiryType_020614.csv'), :headers => true) do |row|

    attrs = {
          :code	       => row[0],
      		:subject       => row[1],
      		:contact_type  => row[2],
          :status	       => 'active'
    }

    # add inquiry_type
    new_inquiry_type = InquiryType.new(attrs)

    # save inquiry_type
    if new_inquiry_type.save 
      puts "Saved inquiry_type #{attrs.inspect}"
    else
      puts new_inquiry_type.errors
    end
  end
end

task :import_user_type => :environment do

  UserType.delete_all
  CSV.foreach(Rails.root.join('db', 'user_type_040114.csv'), :headers => true) do |row|

    attrs = {
      :code	       => row[0],
      :description   => row[1],
      :hide   => row[2],
      :status	       => 'active'
    }

    # add user_type
    new_user_type = UserType.new(attrs)

    # save user_type
    if new_user_type.save 
      puts "Saved user_type #{attrs.inspect}"
    else
      puts new_user_type.errors
    end
  end
end

task :import_faq => :environment do

  Faq.delete_all
  CSV.foreach(Rails.root.join('db', 'faq_043014.csv'), "r:ISO-8859-1") do |row|

    attrs = {
      		:subject       => row[0],
      		:description   => row[1],
      		:question_type => 'inquiry',
          :status	       => 'active'
    }

    # add faq
    new_faq = Faq.new(attrs)

    # save faq
    if new_faq.save 
      puts "Saved faq #{attrs.inspect}"
    else
      puts new_faq.errors
    end
  end
end

desc "Loads the category_types"
task :load_category_types => :environment do
  CSV.foreach(Rails.root.join('db', 'category_type_071514.csv'), :headers => true) do |row|
    attrs = {
      :code => row[0],
      :status => 'active',
      :hide => 'false'
    }

    # find or intialize category_type
    new_category_type = CategoryType.find_or_initialize_by_code(attrs)
    #new_category_type = CategoryType.first_or_initialize(attrs)

    # save category_type
    if new_category_type.save
      puts "Saved category #{attrs.inspect}"
    else
      puts new_category_type.errors
    end
  end 
end

# loads regional data for US cities
task :load_regions => :environment do
  CSV.foreach(Rails.root.join('db', 'region_data_052414.csv'), :headers => true) do |row|
    
    attrs = {
      :name       => row[0],
      :status     => 'active',
      :org_type	  => 'region'
    }

    # add site
    unless site = Site.where(:name => row[0]).first
      new_site = Site.new(attrs)

      # set location/contact attributes
      loc_attrs = { 
        :city    => row[1],
        :state	 => row[2]
      }

      # add contact info for site
      new_site.contacts.build(loc_attrs)

      # save site
      if new_site.save 
        puts "Saved site #{attrs.inspect}"
      else
        puts new_site.errors
      end
    end
  end
end

#load date range
task :load_date_range => :environment do
  DateRange.delete_all
  CSV.foreach(Rails.root.join('db', 'import_date_range.csv'), :headers => true) do |row|
    attrs = {
        :name => row[0]
    }
    new_date_range = DateRange.new(attrs)
    # save date_range
    if new_date_range.save
      puts "Saved date_range #{attrs.inspect}"
    else
      puts new_date_range.errors
    end
  end
end

#loads the data from the db/event_type_071014.csv file into new event_types table.
task :load_event_types => :environment do
  EventType.delete_all
  CSV.foreach(Rails.root.join('db', 'event_type_071014.csv'), :headers => true) do |row|
        attrs = {
            :code       => row[0],
            :description     => row[1],
            :status	   => 'active',
            :hide   => 'false'
        }

            event = EventType.new(attrs)
            if event.save
       			 puts "Saved event #{attrs.inspect}"
      		else
        		puts event.errors
            end
        end
    end

task :load_status_types => :environment do

  StatusType.delete_all
  CSV.foreach(Rails.root.join('db', 'status_type_072314.csv'), :headers => true) do |row|

    attrs = {
      :code     => row[0],
      :hide     => row[1],
    }

    # add status_type
    new_status_type = StatusType.new(attrs)

    # save user_type
    if new_status_type.save 
      puts "Saved status_type #{attrs.inspect}"
    else
      puts new_status_type.errors
    end
  end
end

task :load_condition_types => :environment do
  ConditionType.delete_all
  CSV.foreach(Rails.root.join('db', 'condition_type_110214.csv'), :headers => true) do |row|

    attrs = {
      :code   => row[0],
      :description => row[1],
      :status   => row[2],
      :hide   => row[3],
    }

    #add condition_type
    new_condition_type = ConditionType.new(attrs)

    #save condition_type
    if new_condition_type.save
      puts "Saved condition_type #{attrs.inspect}"
    else
      puts new_condition_type.errors
    end
  end
end

task :load_fulfillment_types => :environment do
  FulfillmentType.delete_all
  CSV.foreach(Rails.root.join('db', 'fulfillment_type_021515.csv'), :headers => true) do |row|

    attrs = {
      :code   => row[0],
      :description => row[1],
      :status   => row[2],
      :hide   => row[3],
    }

    #add fulfillment_type
    new_fulfillment_type = FulfillmentType.new(attrs)

    #save fulfillment_type
    if new_fulfillment_type.save
      puts "Saved fulfillment_type #{attrs.inspect}"
    else
      puts new_fulfillment_type.errors
    end
  end
end

task :import_other_sites, [:file_name, :org_type] => [:environment] do |t, args|

  CSV.foreach(Rails.root.join('db', args[:file_name]), :headers => true) do |row|
    attrs = {
      :name => row[0],
      :status => 'active',
      :org_type => args[:org_type]
    }

    # add site
    unless site = Site.where(:name => row[0]).first
      new_site = Site.new(attrs)

      # set location/contact attributes
      loc_attrs = { 
        :address => row[1],
        :city => row[2],
        :state => row[3],
        :zip => row[4]
      }

      # add contact info for site
      new_site.contacts.build(loc_attrs)

      # save site
      if !new_site.blank? && new_site.save 
        puts "Saved site #{attrs.inspect}"
      else
        puts "Error: #{new_site.errors.full_messages.first}"
      end
    end
  end
end

task :import_travel_modes => :environment do
  TravelMode.delete_all
  CSV.foreach(Rails.root.join('db', 'travel_mode_052415.csv'), :headers => true) do |row|

    attrs = {
      :mode	       => row[0],
      :travel_type     => row[1],
      :description     => row[2],
      :status	       => row[3],
      :hide            => row[4]
    }

    # add travel_mode
    new_travel_mode = TravelMode.new(attrs)

    # save travel_mode
    if new_travel_mode.save 
      puts "Saved travel_mode #{attrs.inspect}"
    else
      puts new_travel_mode.errors
    end
  end
end

task :load_feeds => :environment do
  #Feed.delete_all
  CSV.foreach(Rails.root.join('db', 'site_feed_021515.csv'), :headers => true) do |row|

    attrs = {
      :site_name   => row[0],
      :description => row[1],
      :url         => row[2],
      :site_id     => Site.find_by_name(row[0]).id    # causes task to fail on test database
    }

    # add status_type
    new_feed = Feed.new(attrs)

    # save user_type
    if new_feed.save 
      puts "Saved feed #{attrs.inspect}"
    else
      puts feed.errors      
    end
  end
end

task :load_org_types => :environment do
  OrgType.delete_all
  CSV.foreach(Rails.root.join('db', 'org_type_060215.csv'), :headers => true) do |row|

    hide_val = row[3]
    if hide_val.nil? or hide_val.empty?
      hide_val = "no"
    end
    attrs = {
      :code   => row[0],
      :description => row[1],
      :status   => row[2],
      :hide => hide_val
    }

    #add org_type
    new_org_type = OrgType.new(attrs)

    #save org_type
    if new_org_type.save
      puts "Saved org_type #{attrs.inspect}"
    else
      puts new_org_type.errors
      # puts new_org_type.errors.full_messages
    end
  end
end

#to run all tasks at once
task :run_all_tasks => :environment do

  Rake::Task[:import_sites].execute
  Rake::Task[:load_bay_area_cities].execute
  Rake::Task[:load_sf_neighborhoods].execute
  Rake::Task[:load_zip_codes].execute
  Rake::Task[:load_neighborhoods].execute
  Rake::Task[:load_top_50_cities].execute
  Rake::Task[:load_region_suburbs].execute
  Rake::Task[:load_category_types].execute
  Rake::Task[:load_categories].execute
  Rake::Task[:update_categories].execute
  Rake::Task[:update_category_pictures].execute
  Rake::Task[:import_point_system].execute
  Rake::Task[:import_job_type].execute
  Rake::Task[:import_inquiry_type].execute
  Rake::Task[:import_user_type].execute
  Rake::Task[:import_faq].execute
  Rake::Task[:load_regions].execute
  Rake::Task[:load_event_types].execute
  Rake::Task[:load_status_types].execute
  Rake::Task[:load_condition_types].execute
  Rake::Task[:import_travel_modes].execute
  Rake::Task[:load_feeds].execute
  Rake::Task[:import_other_sites].execute :file_name => "state_site_data_012815.csv", :org_type => "state"
  Rake::Task[:import_other_sites].execute :file_name => "country_site_data_012815.csv", :org_type => "country"
end
