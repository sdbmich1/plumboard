namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do

    # add faker users
    (1..99).each do |n|
      first_name  = Faker::Name.first_name
      last_name  = Faker::Name.last_name
      email = "example-#{n+1}@pixitest.com"
      password  = "password"
      birth_date = 21.years.ago + n.days
      gender = 'Male'

      # create user
      usr = User.new(first_name: first_name, last_name: last_name,
        email: email, birth_date: birth_date, gender: gender,
        password: password,
        password_confirmation: password)

      street = Faker::Address.street_address
      city = Faker::Address.city
      state = Faker::Address.state
      zip_code = Faker::Address.zip_code
      country = 'US'
      phone_number = Faker::PhoneNumber.phone_number

      usr.contacts.build address: street, city: city, state: state, zip: zip_code, home_phone: phone_number, country: country
      usr.save!

      10.times do |i|
        # create listing
        listing = TempListing.new(title: "Test #{n} - #{i} Listing", description: "Test", site_id: 1284, seller_id: usr.id, category_id: i+1, 
		start_date: Time.now)
        picture = listing.pictures.build
        picture.photo = File.new "c:/RoRDev/images/photo#{i}.jpg"
        listing.save!

        # create transaction
        order = { promo_code: '2013LAUNCH', title: listing.title,
              "item1" => 'New Pixi Post', "quantity1" => 1, cnt: 1, qtyCnt: 1, "price1" => 5.00 }
      
        txn = Transaction.load_new usr, listing, order
        txn.save_transaction order, listing

        # reload listing & submit
        new_pixi = TempListing.find_by_pixi_id listing.pixi_id
        new_pixi.approve_order usr
      end
    end
  end
end

