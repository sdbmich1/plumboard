FactoryGirl.define do
  factory :user, aliases: [:recipient, :seller]  do
    first_name            "Joe"
    last_name             "Blow" 
    sequence(:email) {|n| "person#{n}@example.com" }
    password              "setup#123"
    password_confirmation "setup#123"
    gender          	  "Male"
    birth_date            Time.parse("1967-04-23")

    factory :admin do
      before(:create) {|user| user.pictures.build FactoryGirl.attributes_for(:picture)}
      after(:create) {|user| user.add_role(:admin)}
    end

    factory :editor do
      before(:create) {|user| user.pictures.build FactoryGirl.attributes_for(:picture)}
      after(:create) {|user| user.add_role(:editor)}
    end

    factory :subscriber do
      before(:create) {|user| user.pictures.build FactoryGirl.attributes_for(:picture)}
      after(:create) {|user| user.add_role(:subscriber)}
    end
  end

  factory :pixi_user, :class => "User", :parent => :user do
    before(:create) {|user| user.pictures.build FactoryGirl.attributes_for(:picture)}
    after(:create) do |user|
      user.confirm!
      user.confirmed_at		{ Time.now }
    end
  end

  factory :contact_user, :class => "User", :parent => :pixi_user do
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
    before(:create) {|category| category.pictures.build FactoryGirl.attributes_for(:picture)}
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
    acct_number	90009000
    token	"/v1/marketplaces/TEST-MP2Q4OaIanQuIDJIixHGmhQA/bank_accounts/BA7ehO1oDwPUBAR9cz71sd2g"
    before(:create) do |acct|
      acct.create_user FactoryGirl.attributes_for(:pixi_user)
    end
  end

  factory :comment do
    content 		"I love this"
    listing
  end

  factory :pixi_payment do
    pixi_fee		0.99
    token		"/v1/marketplaces/TEST-MP2ORkhLY8htilmM6AlLwBDp/cards/CC3lncKU8HDchttA692Vyyw8"
    invoice
  end
end
		 
