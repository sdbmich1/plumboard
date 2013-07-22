require 'csv'

desc "Import data from csv file"
task :import => :environment do

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

task :load_categories => :environment do

  CSV.foreach(Rails.root.join('db', 'category_data_020613.csv'), :headers => true) do |row|

    attrs = {
	      	:name              => row[0].upcase,
      		:category_type     => row[1],
		:status		   => 'active'
    }

    # find or add category
    new_category = Category.find_or_initialize_by_name(attrs)

    # add photo
    if new_category.pictures.size == 0
      picture = new_category.pictures.build
      picture.photo = File.new "#{Rails.root}" + row[2]
    end

    # save category
    if new_category.save 
      puts "Saved category #{attrs.inspect}"
    else
      puts new_category.errors
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
