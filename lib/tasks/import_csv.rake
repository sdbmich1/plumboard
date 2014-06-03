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
      if new_site.save 
        puts "Saved site #{attrs.inspect}"
      else
        puts new_site.errors
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
        puts new_site.errors
      end
    end
  end
end

# load zip codes for pixi post service areas
task :load_zip_codes => :environment do
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
  
# loads top 50 cities in US
task :load_cities => :environment do
  CSV.foreach(Rails.root.join('db', 'DMA_50_neighborhoods_transposed.csv'), :headers => false) do |row|

    # converting the row to an array by splitting ','
    row_array = row.split(',');

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
end

task :load_categories => :environment do

  CSV.foreach(Rails.root.join('db', 'category_data_020613.csv'), :headers => true) do |row|

    attrs = {
	      	:name              => row[0].titleize,
      		:category_type     => row[1],
		:status		   => 'active'
    }

    # find or add category
    new_category = Category.find_or_initialize_by_name(attrs)

    # add photo
    if new_category.pictures.size == 0
      new_category.pictures.map { |pic| new_category.pictures.delete(pic) }
    end

    picture = new_category.pictures.build
    picture.photo = File.new("#{Rails.root}" + row[2]) if picture

    # save category
    if new_category.save 
      puts "Saved category #{attrs.inspect}"
    else
      puts new_category.errors
    end
  end
end


task :update_categories => :environment do

  CSV.foreach(Rails.root.join('db', 'category_data_042214.csv'), :headers => true) do |row|

    attrs = {:name             => row[1].titleize,
             :category_type    => row[2],
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

