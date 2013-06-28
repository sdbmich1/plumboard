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

    # add site
    new_site = Site.find_or_initialize_by_institution_id(attrs)

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
      picture.photo = File.new row[2]
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
