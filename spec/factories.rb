FactoryGirl.define do
  factory :user do
    first_name            "Joe"
    last_name             "Blow" 
    sequence(:email) {|n| "person#{n}@example.com" }
    password              "setup#123"
    password_confirmation "setup#123"
    gender          	  "Male"
    birth_date            Time.parse("1967-04-23")
  end

  factory :pixi_user, :class => "User", :parent => :user do
    before(:create) do |user|
      user.pictures.build FactoryGirl.attributes_for(:picture)
    end
  end

  factory :admin do
    email                 "jblow@test.com"
    password              "setup#123"
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

  factory :contact do
    address          "123 Elm"
    city            "LA"
    state           "CA"
    zip             "90201"
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
  end

  factory :invalid_listing, :class => "Listing", :parent => :listing_parent do
  end

  factory :temp_listing, :class => "TempListing", :parent => :listing_parent do
    before(:create) do |listing|
      listing.pictures.build FactoryGirl.attributes_for(:picture)
    end
  end

  factory :invalid_temp_listing, :class => "Listing", :parent => :listing_parent do
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
    user
  end

  factory :transaction_detail do
    item_name		'stuff'
    quantity		1
    price		5.00
    transaction
  end
end
		 
