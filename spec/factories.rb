FactoryGirl.define do
  sequence(:email) {|n| "person#{n}@example.com" }
  factory :user, aliases: [:recipient, :seller] do |u|
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
    email 
    password "setup#123"
    password_confirmation "setup#123"
    gender "Male"
    birth_date Time.parse("1967-04-23")
  end

  factory :pixi_user, :class => "User", :parent => :user do
    after(:build) do |usr|
      usr.user_url = usr.name
      usr.pictures.build FactoryGirl.attributes_for(:picture)
      usr.preferences.build FactoryGirl.attributes_for(:preference)
    end
    after(:create) do |usr|
      usr.confirm
      usr.confirmed_at  { Time.now }
    end
  end

  factory :unconfirmed_user, :class => "User", :parent => :user do
    after(:build) do |usr|
      usr.user_url = usr.name
      usr.pictures.build FactoryGirl.attributes_for(:picture)
      usr.preferences.build FactoryGirl.attributes_for(:preference)
    end
  end

  factory :admin, :class => "User", :parent => :pixi_user do
    after(:build) {|usr| usr.user_type_code = 'AD' }
    after(:create) {|usr| usr.add_role(:admin)}
  end

  factory :editor, :class => "User", :parent => :pixi_user do
    after(:create) {|usr| usr.add_role(:editor)}
  end

  factory :pixter, :class => "User", :parent => :pixi_user do
    after(:build) {|usr| usr.user_type_code = 'PT' }
    after(:create) {|usr| usr.add_role(:pixter)}
  end

  factory :support, :class => "User", :parent => :pixi_user do
    after(:create) {|usr| usr.add_role(:support)}
  end

  factory :subscriber, :class => "User", :parent => :pixi_user do
    after(:create) {|usr| usr.add_role(:subscriber)}
  end

  factory :contact_user, :class => "User", :parent => :pixi_user do
    acct_token  "acct_16HJbsDEdnXv7t4y"
    before(:create) do |usr|
      usr.contacts.build FactoryGirl.attributes_for(:contact)
    end
  end

  factory :business_user, :class => "User", :parent => :contact_user do
    after(:build) do |usr| 
      usr.user_type_code = 'BUS' 
      usr.business_name = 'The Community Store' 
      usr.user_url = usr.business_name
    end
  end

  factory :site do
    name "SFSU"
    status  "active"
    site_type_code  "school"
  end

  factory :picture do
    photo { File.new Rails.root.join("spec", "fixtures", "photo.jpg") }
  end

  factory :category do
    name 		"Foo bar"
    category_type_code	"Gigs"
    status 		"active"
    before(:create) {|category| category.pictures.build FactoryGirl.attributes_for(:picture)}
  end

  factory :date_range do
    name "Last Month"
    status "active"
  end

  factory :contact do
    address "123 Elm"
    city "LA"
    state "CA"
    zip "90201"
    home_phone  "4155551212"
  end

  factory :subcategory do
    name "Foobie"
    subcategory_type  "Gigs"
    status "active"
    before(:create) {|cat| cat.pictures.build FactoryGirl.attributes_for(:picture)}
    category
  end

  factory :promo_code do
    owner_id 1
    code  "2013LAUNCH"
    promo_name "2013LAUNCH"
    description "2013LAUNCH"
    promo_type  "Launch"
    status "active"
    amountOff nil
    percentOff  100
    site_id 1
    max_redemptions 100
    start_date  nil
    end_date  nil
    start_time  nil
    end_time  nil
    currency  "US"
  end

  factory :listing_parent do
    title "Acoustic guitar - $100 Barely Used"
    description "check it out"
    alias_name  "jkjfj34kjkj"
    seller_id 1
    start_date  { Time.now }
    end_date  { Time.now+7.days }
    status  "active"
    price 100.00
    category_id 1
    site_id 1
    quantity 1
    transaction_id  1
    show_alias_flg  "no"
    show_phone_flg  "no"
    pixi_id { rand(36**8).to_s(36) }
    parent_pixi_id  "1"
    site
    category
    fulfillment_type
  end

  factory :listing, :class => "Listing", :parent => :listing_parent do
    after(:build) do |listing|
      listing.pictures.build FactoryGirl.attributes_for(:picture)
    end

    ignore do
      sites_count 3
    end

    factory :listing_with_post do
      after(:create) do |listing|
        listing.posts.build FactoryGirl.attributes_for(:post, :pixi_id => listing.pixi_id)
      end
    end
  end

  factory :listing_with_pictures, :class => "Listing", :parent => :listing_parent do
    before(:create) do |listing|
      2.times { listing.pictures.build FactoryGirl.attributes_for(:picture) }
    end
  end

  factory :invalid_listing, :class => "Listing", :parent => :listing_parent do
  end

  factory :temp_listing, :class => "TempListing", :parent => :listing_parent do
    status  "new"
    after(:build) do |listing|
      listing.pictures.build FactoryGirl.attributes_for(:picture)
    end
  end

  factory :temp_listing_with_pictures, :class => "TempListing", :parent => :listing_parent do
    status  "new"
    before(:create) do |listing|
      2.times { listing.pictures.build FactoryGirl.attributes_for(:picture) }
    end
  end

  factory :temp_listing_with_transaction, :class => "TempListing", :parent => :listing_parent do
    status  'pending'
    before(:create) do |listing|
      listing.pictures.build FactoryGirl.attributes_for(:picture)
    end
    transaction
  end

  factory :invalid_temp_listing, :class => "TempListing", :parent => :listing_parent do
    status  "new"
  end

  factory :old_listing, :class => "OldListing", :parent => :listing_parent do
    before(:create) do |listing|
      listing.pictures.build FactoryGirl.attributes_for(:picture)
    end
  end

  factory :interest do
    name "furniture"
    status  "active"
  end

  factory :post do
    content "SFSU"
    user
    recipient
  end

  factory :conversation do
    user
    recipient
  end

  factory :invoice do
    comment 'stuff'
    quantity  2
    price 185.00
    sales_tax 8.25
    tax_total 30.52
    inv_date  Time.now
    subtotal  370.00
    amount  400.52
    status  'unpaid'
    before(:create) do |inv|
      inv.invoice_details.build FactoryGirl.attributes_for(:invoice_detail)
    end
  end

  factory :invoice_detail do
    quantity  2
    price 185.00
    subtotal  370.00
  end

  factory :transaction do
    first_name "Joe"
    last_name "Blow"
    email "jblow@test.com"
    address "123 Elm"
    city "LA"
    state "CA"
    zip "90201"
    country "US"
    home_phone  "1234567890"
    amt 100.00
    convenience_fee 0.99
    processing_fee 0.99
    status  'pending'
    transaction_type  'pixi'
    token { rand(36**8).to_s(36) }
    #before(:create) do |txn|
    #  txn.create_user FactoryGirl.attributes_for(:pixi_user)
    #end
  end

  factory :balanced_transaction, :class => "Transaction", :parent => :transaction do
    token "/v1/marketplaces/TEST-MP2Q4OaIanQuIDJIixHGmhQA/cards/CC6HczhlX2JS7HBZQUXNaEK4"
  end

  factory :transaction_detail do
    item_name 'stuff'
    quantity  1
    price 5.00
    transaction
  end

  factory :pixi_point do
    category_name 'Post'
    action_name 'Post Pixi'
    code  'ppx'
    value 5
  end

  factory :user_pixi_point do
    code  'ppx'
    before(:create) do |user|
      user.create_user FactoryGirl.attributes_for(:pixi_user)
    end
  end

  factory :bank_account do
    acct_name "Joe's Checking"
    status  'active'
    acct_type 'checking'
    acct_number '123456789'
    acct_no '6789'
    currency_type_code 'usd'
    country_code 'us'
    token "ba_16HJc8DEdnXv7t4ytCIXAzAs"
  end

  factory :card_account do
    status  'active'
    card_type 'visa'
    card_number '9000900090001111'
    card_no 9000
    expiration_month 6
    expiration_year Date.today.year+2
    token "/v1/marketplaces/TEST-MP2Q4OaIanQuIDJIixHGmhQA/cards/CC4kUNrs7OjmVpLeCT6PPSHE"
    zip '90201'
  end

  factory :comment do
    content "I love this"
  end

  factory :pixi_payment do
    pixi_fee  0.99
    token "/v1/marketplaces/TEST-MP2ORkhLY8htilmM6AlLwBDp/cards/CC3lncKU8HDchttA692Vyyw8"
  end

  factory :inquiry do
    first_name  "Jane"
    last_name "Doe"
    email "jane.doe@pixitest.com"
    code  "WS"
    comments "How can I change profiles?"
    status "active"
  end

  factory :rating do
    comments "A+ rating"
    value 4
  end

  factory :pixi_post do
    preferred_date  { Time.now+7.days }
    alt_date  { Time.now+7.days }
    preferred_time  { Time.now+7.days }
    alt_time  { Time.now+7.days }
    address "123 Elm"
    city "LA"
    state "CA"
    zip "90201"
    description "Black leather sofa"
    quantity  1
    value 100
    home_phone  '4158673143'
    status "active"
  end

  factory :pixi_post_zip do
    zip 90201
    city "LA"
    state "CA"
    status "active"
  end

  factory :job_type do
    code  "CT"
    job_name  "Contract"
    status  "active"
  end

  factory :inquiry_type do
    code  "WS"
    contact_type  "support"
    subject "Website"
    status  "active"
  end

  factory :user_type do
    code  "PX"
    description "Pixan"
    status  "active"
  end

  factory :faq do
    question_type "Payment"
    subject "How do I pay?"
    description "You can use your PixiPay account."
    status  "active"
  end

  factory :pixi_like do
    user_id 1
    pixi_id "xxxx"
  end

  factory :pixi_want do
    user_id 1
    pixi_id "xxxx"
    quantity 1
    status 'active'
  end

  factory :saved_listing do
    user_id 1
    pixi_id "xxxx"
  end

  factory :preference do
    zip '90201'
    email_msg_flg 'yes'
    mobile_msg_flg 'yes'
  end
  
  factory :event_type do
      code		"perform"
      description		"performance"
      status		"active"
      hide      "false"
  end

  factory :category_type do
    code "sales"
    hide "false"
    status "active"
  end

  factory :inactive_category_type, :class => "CategoryType" do
    code "sales"
    hide "false"
    status "inactive"
  end

  factory :status_type do
    code "active"
  end

  factory :condition_type do
    code "N"
    hide "no"
    status "active"
    description 'New'
  end
        
  factory :site_type do
    code "N"
    hide "no"
    status "active"
    description "school"
  end                    

  factory :fulfillment_type do
    code "SHP"
    hide "no"
    status "active"
    description 'Ship'
  end

  factory :pixi_ask do
    user_id 1
    pixi_id "xxxx"
  end

  factory :feed do
    site_name "SF Bay Area"
    description "SF Examiner"
    url "http://www.sfexaminer.com/sanfrancisco/Rss.xml?section=2124643"
  end

  factory :pixi_post_detail do
    pixi_post_id 1
    pixi_id "xxxx"
  end

  factory :favorite_seller do
    user_id 1
    seller_id 2
    status "active"
  end

  factory :travel_mode do
    mode  "DR"
    travel_type "Car"
    description "Driving"
    status  "active"
    hide "no"
  end

  factory :state do
    code  "CA"
    state_name  "California"
  end

  factory :currency_type do
    code "USD"
    description "United States Dollar"
    hide "no"
    status "active"
  end
  
  factory :stock_image do
    title "Programmer"
    file_name "Computer.jpg"
    category_type_code "employment"
  end

  factory :plan do
    name 'Starter'
    price 0
    interval 'month'
    trial_days 30
    status 'active'
  end

  factory :subscription

  factory :device do
    token { (Time.now.hash).abs.to_s }
    status 'active'
  end

  factory :message_type do
    status 'active'
  end

  factory :message do
  end

  factory :promo_code_user do
    user_id 1
    promo_code_id 1
    status 'active'
  end
end
