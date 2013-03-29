FactoryGirl.define do
  factory :user do
    first_name            "Joe"
    last_name             "Blow" 
    sequence(:email) {|n| "person#{n}@example.com" }
    password              "setup#123"
    password_confirmation "setup#123"
    gender          	  "Male"
    birth_date            Time.parse("1967-04-23")

    factory :admin do
      after(:create) {|user| user.add_role(:admin)}
    end

    factory :editor do
      after(:create) {|user| user.add_role(:editor)}
    end

    factory :subscriber do
      after(:create) {|user| user.add_role(:subscriber)}
    end
  end

  factory :pixi_user, :class => "User", :parent => :user do
    before(:create) do |user|
      user.pictures.build FactoryGirl.attributes_for(:picture)
    end
  end

  factory :contact_user, :class => "User", :parent => :user do
    before(:create) do |user|
      user.contacts.build FactoryGirl.attributes_for(:contact)
    end
  end

  factory :state do
    code		"CA"
    state_name		"California"
  end

  factory :site do
    name 		"SFSU"
    status		"active"
  end

  factory :category do
    name 		"Foo bar"
    category_type	"Gigs"
    status 		"active"
  end

  factory :promo_code do
    code		"2013LAUNCH"
    promo_name 		"2013LAUNCH"
    description		"2013LAUNCH"
    promo_type		"Launch"
    status 		"active"
    amountOff		nil
    percentOff		100
    site_id		1
    max_redemptions	100
    start_date		nil
    end_date		nil
    start_time		nil
    end_time		nil
    currency		"US"
  end

  factory :contact do
    address          "123 Elm"
    city            "LA"
    state           "CA"
    zip             "90201"
    home_phone	    "4155551212"
  end

  factory :listing_parent do
    title		"Acoustic guitar - $100 Barely Used"
    description		"check it out"
    alias_name		"jkjfj34kjkj"
    seller_id		1
    start_date		{ Time.now }
    end_date		{ Time.now+7.days }
    status		"active"
    price		5.00
    category_id		1
    site_id		1
    transaction_id	1
    show_alias_flg	"no"
    show_phone_flg	"no"
    pixi_id		{ rand(36**8).to_s(36) }
    parent_pixi_id	"1"
    site
    category
  end

  factory :listing, :class => "Listing", :parent => :listing_parent do
    before(:create) do |listing|
      listing.pictures.build FactoryGirl.attributes_for(:picture)
    end

    ignore do
      sites_count 3
    end

    factory :listing_with_sites do
      after(:create) do |listing, x|
        FactoryGirl.create_list(:site_listing, x.sites_count, :listing => listing)
	x.reload
      end
    end
  end

  factory :invalid_listing, :class => "Listing", :parent => :listing_parent do
  end

  factory :temp_listing, :class => "TempListing", :parent => :listing_parent do
    before(:create) do |listing|
      listing.pictures.build FactoryGirl.attributes_for(:picture)
    end
  end

  factory :temp_listing_with_pictures, :class => "TempListing", :parent => :listing_parent do
    before(:create) do |listing|
      2.times { listing.pictures.build FactoryGirl.attributes_for(:picture) }
    end
  end

  factory :temp_listing_with_transaction, :class => "TempListing", :parent => :listing_parent do
    status	'pending'
    before(:create) do |listing|
      listing.pictures.build FactoryGirl.attributes_for(:picture)
    end
    transaction
  end

  factory :invalid_temp_listing, :class => "TempListing", :parent => :listing_parent do
  end

  factory :interest do
    name 		"furniture"
    status		"active"
  end

  factory :post do
    content 		"SFSU"
    user
    listing
  end

  factory :site_listing do
    site
    listing
  end

  factory :picture do
    photo { File.new Rails.root.join("spec", "fixtures", "photo.jpg") }
  end

  factory :transaction do
    first_name          "Joe"
    last_name           "Blow" 
    email               "jblow@test.com"
    address          	"123 Elm"
    city            	"LA"
    state           	"CA"
    zip             	"90201"
    country		"US"
    home_phone		"1234567890"
    amt			100.00
    status		'pending'
    user
  end

  factory :transaction_detail do
    item_name		'stuff'
    quantity		1
    price		5.00
    transaction
  end
end
		 
