FactoryGirl.define do
  factory :user do
    first_name            "Joe"
    last_name             "Blow" 
    email                 "jblow@test.com"
    password              "setup#123"
    password_confirmation "setup#123"
    gender          	  "Male"
    birth_date            Time.parse("1967-04-23")
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

  factory :listing do
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
    site
    category
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
    listing
    site
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
		 
