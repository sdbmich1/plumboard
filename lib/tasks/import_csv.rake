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

task :category => :environment do

  CSV.foreach(Rails.root.join('db', 'category_data_020613.csv'), :headers => true) do |row|

    attrs = {
	      	:name              => row[0].upcase,
      		:category_type     => row[1],
		:status		   => 'active'
    }

    # add category
    new_category = Category.new(attrs)

    # save category
    if new_category.save 
      puts "Saved category #{attrs.inspect}"
    else
      puts new_category.errors
    end
  end
end
