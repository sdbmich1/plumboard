FactoryGirl.define do
  sequence(:email) {|n| "person#{n}@example.com" }
  factory :user, aliases: [:recipient, :seller] do
    first_name            { Faker::Name.first_name }
    last_name             { Faker::Name.last_name }
    email		  
    password              "setup#123"
    password_confirmation "setup#123"
    gender          	  "Male"
    birth_date            Time.parse("1967-04-23")
  end

    factory :admin, :class => "User", :parent => :user do
      before(:create) {|usr| usr.pictures.build FactoryGirl.attributes_for(:picture)}
      after(:create) {|usr| usr.add_role(:admin)}
    end

    factory :editor, :class => "User", :parent => :user do
      before(:create) {|usr| usr.pictures.build FactoryGirl.attributes_for(:picture)}
      after(:create) {|usr| usr.add_role(:editor)}
    end

    factory :subscriber, :class => "User", :parent => :user do
      before(:create) {|usr| usr.pictures.build FactoryGirl.attributes_for(:picture)}
      after(:create) {|usr| usr.add_role(:subscriber)}
    end

  factory :pixi_user, :class => "User", :parent => :user do
    after(:build) do |usr| 
      usr.pictures.build FactoryGirl.attributes_for(:picture)
    end
    after(:create) do |usr|
      usr.confirm!
      usr.confirmed_at		{ Time.now }
    end
  end

  factory :contact_user, :class => "User", :parent => :pixi_user do
    card_token		"/v1/customers/CU3HH3hlEKbL04U2GOKgX8o2"
    before(:create) do |usr|
      usr.contacts.build FactoryGirl.attributes_for(:contact)
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

  factory :picture do
    photo { File.new Rails.root.join("spec", "fixtures", "photo.jpg") }
  end

  factory :category do
    name 		"Foo bar"
    category_type	"Gigs"
    status 		"active"
    before(:create) {|category| category.pictures.build FactoryGirl.attributes_for(:picture)}
  end

  factory :contact do
    address          "123 Elm"
    city            "LA"
    state           "CA"
    zip             "90201"
    home_phone	    "4155551212"
  end

  factory :subcategory do
    name 		"Foobie"
    subcategory_type	"Gigs"
    status 		"active"
    before(:create) {|cat| cat.pictures.build FactoryGirl.attributes_for(:picture)}
    category
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

  factory :listing_parent do
    title		"Acoustic guitar - $100 Barely Used"
    description		"check it out"
    alias_name		"jkjfj34kjkj"
    seller_id		1
    start_date		{ Time.now }
    end_date		{ Time.now+7.days }
    status		"active"
    price		100.00
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

    factory :listing_with_post do
      after(:create) do |listing|
        listing.posts.build FactoryGirl.attributes_for(:post, :pixi_id => listing.pixi_id)
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

  factory :old_listing, :class => "OldListing", :parent => :listing_parent do
    before(:create) do |listing|
      listing.pictures.build FactoryGirl.attributes_for(:picture)
    end
  end

  factory :interest do
    name 		"furniture"
    status		"active"
  end

  factory :post do
    content 		"SFSU"
    user
    recipient
  end

  factory :invoice do
    comment		'stuff'
    quantity		2
    price		185.00
    sales_tax		8.25
    tax_total		30.52
    inv_date		Time.now
    subtotal		370.00
    amount		400.52
    status		'unpaid'
  end

  factory :site_listing do
    site
    listing
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
    transaction_type	'pixi'
    token		{ rand(36**8).to_s(36) }
    before(:create) do |txn|
      txn.create_user FactoryGirl.attributes_for(:pixi_user)
    end
  end

  factory :balanced_transaction, :class => "Transaction", :parent => :transaction do
    token		"/v1/marketplaces/TEST-MP2Q4OaIanQuIDJIixHGmhQA/cards/CC6HczhlX2JS7HBZQUXNaEK4"
  end

  factory :transaction_detail do
    item_name		'stuff'
    quantity		1
    price		5.00
    transaction
  end

  factory :pixi_point do
    category_name	'Post'
    action_name		'Post Pixi'
    code		'ppx'
    value		5
  end

  factory :user_pixi_point do
    code		'ppx'
    before(:create) do |user|
      user.create_user FactoryGirl.attributes_for(:pixi_user)
    end
  end

  factory :bank_account do
    acct_name	"Joe's Checking"
    status		'active'
    acct_type	'checking'
    acct_number	'90009000'
    token	"/v1/marketplaces/TEST-MP2Q4OaIanQuIDJIixHGmhQA/bank_accounts/BA7ehO1oDwPUBAR9cz71sd2g"
  end

  factory :card_account do
    status		'active'
    card_type	'visa'
    card_number	'9000900090009000'
    card_no	9000
    expiration_month   6
    expiration_year    2018
    token	"/v1/marketplaces/TEST-MP2Q4OaIanQuIDJIixHGmhQA/cards/CC5yjh7ElKiRFu5oArBZ8wmy"
  end

  factory :comment do
    content 		"I love this"
  end

  factory :pixi_payment do
    pixi_fee		0.99
    token		"/v1/marketplaces/TEST-MP2ORkhLY8htilmM6AlLwBDp/cards/CC3lncKU8HDchttA692Vyyw8"
  end

  factory :inquiry do
    first_name		"Jane"
    last_name		"Doe"
    email		"jane.doe@pixitest.com"
    code		"WS"
    comments 		"How can I change profiles?"
    status 		"active"
  end

  factory :rating do
    comments 		"A+ rating"
    value 		4
  end

  factory :pixi_post do
    preferred_date	{ Time.now+2.days }
    alt_date		{ Time.now+7.days }
    preferred_time	{ Time.now+2.days }
    alt_time		{ Time.now+7.days }
    address          "123 Elm"
    city            "LA"
    state           "CA"
    zip             "90201"
    description 	"Black leather sofa"
    quantity		1
    value 		100
    status 		"active"
  end

  factory :job_type do
    code		"CT"
    job_name		"Contract"
    status		"active"
  end

  factory :inquiry_type do
    code		"WS"
    contact_type	"support"
    subject		"Website"
    status		"active"
  end
end
