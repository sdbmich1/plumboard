require 'spec_helper'
require "rack_session_access/capybara"

feature "TempListings" do
  subject { page }
  let(:user) { create(:pixi_user) }
  let(:seller) { create(:contact_user) }
  let(:admin) { create :admin, user_type_code: 'AD', confirmed_at: Time.now }
  let(:pixter) { create :pixter, user_type_code: 'PT', confirmed_at: Time.now }
  let(:business_user) { create :business_user }
  let(:submit) { "Next" }

  before(:each) do
    create_sites
    create_categories
    create_event_types
    create_job_types
    create_condition_types
    create_fulfillment_types
  end

  def create_sites
    @site = create :site, name: 'Santa Clara University'
    @site1 = create :site
    create :site, name: 'Stanford University'
    create :site, name: 'San Francisco - Nob Hill'
  end
  
  def create_job_types
    create :job_type
    create :job_type, code: 'FT', job_name: 'Full-Time'
  end

  def create_event_types
    create :event_type
    create :event_type, code: 'vol', description: 'volunteer'
  end

  def create_condition_types
    create :condition_type
    create :condition_type, code: 'U', description: 'Used'
  end

  def create_fulfillment_types
    create :fulfillment_type
    create :fulfillment_type, code: 'P', description: 'Pickup', status: 'active', hide: 'no'
  end

  def add_data val='Foo Bar', prcFlg=true, imgFlg=false, descr="Guitar for Sale", sFlg=true
    fill_in 'Title', with: "Guitar for Sale"
    select_category val if val
    if sFlg
      fill_autocomplete 'site_name', with: "Stanford University"
    end
    fill_in 'Price', with: "150.00" if prcFlg
    fill_in 'Description', with: descr
  end

  def add_photo val, prcFlg=true, imgFlg=false, descr="Guitar for Sale", sFlg=true
    page.attach_file('photo', "#{Rails.root}/spec/fixtures/photo.jpg")
    add_data val, prcFlg, imgFlg, descr, sFlg
  end

  def build_page_content val=0
    page.should have_content "Build Your Pixi"
    @loc = @site.id
    stub_const("MIN_PIXI_COUNT", val)
    expect(MIN_PIXI_COUNT).to eq(val)
    page.should have_selector('.sm-thumb')
    page.should have_selector('#photo')
    page.should have_selector('#pixi-cancel-btn', href: local_listings_path(loc: @loc))
    page.should have_button 'Next'
  end

  def set_site_id sid, jsFlg=false
    if jsFlg
      page.execute_script %Q{ $('#site_id').val("#{sid}") }
    else
      find(:xpath, "//input[@id='site_id']").set sid
    end
  end

  def create_categories
    create :category_type, code: 'event'
    create :category_type, code: 'product'
    create :category_type, code: 'sales'
    create :category_type, code: 'service'
    create :category_type, code: 'vehicle'
    create :category_type, code: 'employment'
    create :category 
    @cat4 = create :category, name: 'Automotive', category_type_code: 'vehicle'
    @cat = create :category, name: 'Events', category_type_code: 'event'
    @cat3 = create :category, name: 'Deals', category_type_code: 'service'
    create :category, name: 'Books', category_type_code: 'sales'
    @cat2 = create :category, name: 'Apparel', category_type_code: 'product'
    @cat5 = create :category, name: 'Jobs', category_type_code: 'employment'
    create :category, name: 'Foo Bar', category_type_code: 'foobar'
  end

  def set_event_type val
    find(:xpath, "//input[@id='et_code']").set val
  end

  def select_site val='SF', result='SFSU'
    # select("SFSU", :from => "temp_listing_site_id")
    fill_in "site_name", :with => val
    fill_autocomplete result, "#site_name"
  end

  def select_category val
    select(val, :from => 'temp_listing_category_id')
  end

  def select_date fld
    page.execute_script %Q{ $("##{fld}").trigger("focus") } # activate datetime picker
    page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
    page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15
  end

  def show_photo_fld
    script = "$('.SI-FILES-STYLIZED label').removeClass('cabinet'); " # hide the label
    script << "$('#photo').css({opacity: 100, display: 'block'}); "
    page.execute_script(script)
  end

  def add_pixi val='Foo Bar', prcFlg=true, imgFlg=false, descr="Guitar for Sale", sFlg=true
    expect{
      add_photo val, prcFlg, imgFlg, descr, sFlg
      click_button submit; sleep 3
    }.to change(TempListing,:count).by(1)
    page.should have_content "Guitar For Sale"
    page.should have_content 'Review Your Pixi'
  end

  describe "login sets session" do
    before :each do
      set_temp_attr ''
      @temp = TempListing.add_listing(@attr, User.new)
      @temp.save!
      page.set_rack_session(back_to: "/temp_listings/#{@temp.pixi_id}")
      page.set_rack_session(guest_user_id: @temp.user.id)
      visit new_user_session_path
    end
    it 'assigns temp_listing to signed in user' do
      user_login user
      page.should have_content 'Review Your Pixi'
      page.should have_content @temp.pixi_id
      page.should have_content user.first_name
      expect(@temp.reload.seller_id).to eq user.id
    end

    it "creates a listing and signs in w/ FB", js: true do
      omniauth
      click_on "fb-btn"
      page.should have_content 'Review Your Pixi'
      page.should have_content 'Bob'
    end
  end

  describe "Manage Temp Pixis" do
    let(:temp_listing) { build(:temp_listing) }
    before(:each) do
      init_setup user
      visit new_temp_listing_path
    end

    it 'shows content' do
      build_page_content
    end

    it 'shows content w local listings home' do
      build_page_content 500
      create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id, site_id: @loc ) 
      expect(Listing.active.count).not_to eq(0)
    end

    def event_data sdt, edt
      add_photo 'Events', true, true
      fill_in 'start-date', with: sdt
      fill_in 'end-date', with: edt
    end

    describe "Create with invalid information", js: true do
      before :each do
        init_setup user
      end

      it "should not create a listing" do
        expect { click_button submit }.not_to change(TempListing, :count)
      end

      it "does not create a listing w/o site" do
        expect { 
          fill_in 'Title', with: "Guitar for Sale"
          fill_in 'Price', with: "150.00"
          select_category 'Foo Bar'
          fill_in 'Description', with: "Guitar for Sale"
          attach_file('photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
	  click_button submit }.not_to change(TempListing, :count)
      end

      it "does not create a listing w/o category" do
        expect { 
	  add_photo nil, true, true
	  click_button submit }.not_to change(TempListing, :count)
      end

      it "does not create a listing w/o description" do
        expect { 
	  add_photo 'Foo Bar', true, true, nil
	  click_button submit }.not_to change(TempListing, :count)
      end

      it "does not create a listing w/o start date" do
        expect { 
	  add_photo 'Events', true, true
          page.should have_selector('#et_code', visible: true) 
          select('Performance', :from => 'et_code'); sleep 0.5
	  click_button submit }.not_to change(TempListing, :count)
      end

      it "does not create a listing w/ bad start date" do
        expect { 
	  event_data "30/30/2456", Date.today().strftime('%m/%d/%Y')
	  click_button submit }.not_to change(TempListing, :count)
      end

      it "does not create a listing w/ invalid start date" do
        expect { 
	  event_data Date.yesterday.strftime('%m/%d/%Y'), Date.today().strftime('%m/%d/%Y')
	  click_button submit }.not_to change(TempListing, :count)
      end

      it "does not create a listing w/o end date" do
        expect { 
	  event_data Date.today().strftime('%m/%d/%Y'), nil
	  click_button submit }.not_to change(TempListing, :count)
      end

      it "does not create a listing w/ bad end date" do
        expect { 
	  event_data Date.today().strftime('%m/%d/%Y'), "30/30/2456"
	  click_button submit }.not_to change(TempListing, :count)
      end

      it "does not create a listing w/ invalid end date" do
        expect { 
	  event_data Date.today().strftime('%m/%d/%Y'), Date.yesterday.strftime('%m/%d/%Y') 
	  click_button submit }.not_to change(TempListing, :count)
      end

      it "should not create a listing w/o photo" do
        expect { 
	  add_photo 'Foo Bar', true, true
	  click_button submit }.not_to change(TempListing, :count)
	  page.should have_content "Must have at least one picture"
      end
    end

    describe "Create with valid information", base: true do
      it "Adds a new listing w/o price", js: true do
        expect{
	  add_photo 'Foo Bar', false
          select('Used', :from => 'cond-type-code')
	  click_button submit; sleep 3
          page.should have_content 'Review Your Pixi'
          page.should have_content "Guitar for Sale" 
	}.to change(TempListing,:count).by(1)
      end	      

      it "Adds a new listing w price", js: true do
        select('Used', :from => 'cond-type-code')
        add_pixi
      end	      

      it "Adds a new listing w compensation", js:true do
        expect{
	  add_photo 'Jobs', false, true; sleep 2
	  check_page_selectors ['#temp_listing_job_type_code', '#salary'], true, false
 	  check_page_selectors ['#start-date', '#end-date', '#start-time', '#end-time', '#pixi_qty', '#et_code', '#cond-type-code', '#yr_built', 
	    '#temp_listing_mileage', '#temp_listing_item_color', '#temp_listing_item_id', '#temp_listing_product_size', '#temp_listing_car_id', 
	    '#temp_listing_car_color', '#temp_listing_price'], false, false
          select('Full-Time', :from => 'temp_listing_job_type_code')
          fill_in 'salary', with: "Competitive"
	}.to change(TempListing,:count).by(0)
      end	      

      it "Adds a new vehicle listing", js:true  do
        expect{
  	  add_photo 'Automotive', true, true; sleep 3
          fill_in 'Title', with: "Buick Regal for sale"
	  check_page_selectors ['#cond-type-code', '#yr_built', '#temp_listing_mileage', '#temp_listing_car_color', '#temp_listing_car_id'], true, false
 	  check_page_selectors ['#start-date', '#end-date', '#start-time', '#end-time', '#pixi_qty', '#et_code', '#temp_listing_job_type_code', '#salary',
	    '#temp_listing_product_size', '#temp_listing_product_color', '#temp_listing_item_color', '#temp_listing_item_id'], false, false
          select('Used', :from => 'cond-type-code')
          select('2001', :from => 'yr_built')
          fill_in 'temp_listing_mileage', with: "100,000"
          fill_in 'temp_listing_car_color', with: "Baby Blue"
          fill_in 'temp_listing_car_id', with: "ABCDEF1234567890"
	}.to change(TempListing,:count).by(0)
      end	      

      it "Adds a new event listing", js:true do
        expect{
	  add_photo 'Events', true, true
	  check_page_selectors ['#temp_listing_job_type_code', '#salary', '#cond-type-code', '#yr_built', '#temp_listing_mileage', 
	    '#temp_listing_mileage', '#temp_listing_item_color', '#temp_listing_item_id', '#temp_listing_product_size', '#temp_listing_car_id', 
	    '#temp_listing_car_color'], false, false
 	  check_page_selectors ['#start-date', '#end-date', '#start-time', '#end-time', '#pixi_qty', '#et_code'], true, false
          select('Performance', :from => 'et_code'); sleep 0.5
          select('1', :from => 'pixi_qty'); sleep 0.5
          fill_in 'start-date', with: Date.today().strftime('%m/%d/%Y')
          fill_in 'end-date', with: Date.today().strftime('%m/%d/%Y')
  	  select('5:00 PM', :from => 'start-time')
	  select('10:00 PM', :from => 'end-time')
	}.to change(TempListing,:count).by(0)
      end	      

      it "Adds a new product listing", js:true  do
        expect{
  	  add_photo 'Apparel', true, true; sleep 3
          fill_in 'Title', with: "Cosby Sweater"
	  check_page_selectors ['#cond-type-code','#pixi_qty', '#temp_listing_item_color', '#temp_listing_item_id', '#temp_listing_product_size'], true, 
	  false 
 	  check_page_selectors ['#start-date', '#end-date', '#start-time', '#end-time','#et_code','#temp_listing_job_type_code', '#salary','#yr_built', 
	  '#temp_listing_mileage', '#temp_listing_car_id', '#temp_listing_car_color'], false, false
          select('Used', :from => 'cond-type-code')
          select('4', :from => 'pixi_qty'); sleep 0.5
          fill_in 'temp_listing_item_color', with: "Baby Blue"
          fill_in 'temp_listing_product_size', with: "Large"
          fill_in 'temp_listing_item_id', with: "ABCDEF1234567890"
	}.to change(TempListing,:count).by(0)
      end	      

      it "Adds a new sales listing", js:true  do
        expect{
  	  add_photo 'Books', true, true; sleep 3
          fill_in 'Title', with: "Harry Potter"
	  check_page_selectors ['#cond-type-code','#pixi_qty'], true, false
 	  check_page_selectors ['#start-date', '#end-date', '#start-time', '#end-time', '#et_code', '#temp_listing_job_type_code', '#salary','#yr_built', '#temp_listing_mileage', '#temp_listing_car_color', '#temp_listing_car_id', '#temp_listing_product_size', '#temp_listing_item_color'], false, false
          select('Used', :from => 'cond-type-code')
          select('4', :from => 'pixi_qty'); sleep 0.5
	}.to change(TempListing,:count).by(0)
      end	      

      it "Adds a new service listing", js:true  do
        expect{
  	  add_photo 'Deals', true, true; sleep 3
          fill_in 'Title', with: "Harry Potter"
	  check_page_selectors ['#temp_listing_price'], true, false
 	  check_page_selectors ['#cond-type-code', '#start-date', '#end-date', '#start-time', '#end-time', '#et_code', '#temp_listing_job_type_code',
	  '#salary','#yr_built', '#temp_listing_mileage', '#temp_listing_item_color','#temp_listing_car_color', '#temp_listing_car_id', 
	  '#temp_listing_product_size', '#pixi_qty'], false, false
	}.to change(TempListing,:count).by(0)
      end	      
    end	      
  end

  describe "Edit Invalid Temp Pixi" do 
    let(:temp_listing) { create(:temp_listing) }
    before :each do
      init_setup user
      visit edit_temp_listing_path(temp_listing) 
    end

    it 'shows content' do
      @loc = @site.id
      stub_const("MIN_PIXI_COUNT", 0)
      expect(MIN_PIXI_COUNT).to eq(0)
      page.should have_selector('.sm-thumb')
      page.should have_selector('#photo')
      page.should have_selector('#pixi-cancel-btn', href: categories_path(loc: @loc))
      page.should have_button 'Next'
    end

    it 'shows content w local listings home' do
      @loc = @site.id
      create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id, site_id: @loc ) 
      stub_const("MIN_PIXI_COUNT", 500)
      expect(MIN_PIXI_COUNT).to eq(500)
      page.should have_selector('.sm-thumb')
      page.should have_selector('#photo')
      expect(Listing.active.count).not_to eq(0)
      page.should have_selector('#pixi-cancel-btn', href: local_listings_path(loc: @loc))
      page.should have_button 'Next'
    end

    it "empty title should not change a listing" do
      expect { 
	      fill_in 'Title', with: nil
	      click_button submit 
	}.not_to change(TempListing, :count)
      page.should have_content 'Build Pixi'
    end

    it "empty description should not change a listing" do
      expect { 
	      fill_in 'Description', with: nil
	      click_button submit 
	}.not_to change(TempListing, :count)
      page.should have_content 'Build Pixi'
    end

    it "invalid price should not change a listing" do
      expect { 
	      fill_in 'Price', with: '$500'
	      click_button submit 
	}.not_to change(TempListing, :count)
      page.should have_content 'Build Pixi'
    end

    it "huge price should not change a listing" do
      expect { 
	      fill_in 'Price', with: '5000000'
	      click_button submit 
	}.not_to change(TempListing, :count)
      page.should have_content 'Build Pixi'
    end

    it "should not add a large pic" do
      expect{
              attach_file('photo', Rails.root.join("spec", "fixtures", "photo2.png"))
              click_button submit
      }.not_to change(temp_listing.pictures,:count).by(-1)
      page.should have_content 'Build Pixi'
    end
  end

  describe "Edit Temp Pixi" do 
    let(:temp_listing) { create(:temp_listing_with_pictures, condition_type_code: 'U', quantity: 3) }
    before do
      init_setup user
      create_sites
      visit edit_temp_listing_path(temp_listing) 
    end

    it 'shows content' do
      page.should have_selector('.sm-thumb')
      page.should have_selector('#photo')
      page.should have_button 'Next'
    end

    it "Changes a pixi title", js: true do
      expect{
	      fill_in 'Title', with: "Guitar for Sale"
              click_button submit
      }.to change(TempListing,:count).by(0)
      page.should have_content 'Guitar For Sale'
      page.should have_content 'Review Your Pixi'
    end

    it "Changes a pixi site", js: true do
      page.should have_css('#site_id', :visible => false)
      expect{
              set_site_id @site.id, true; sleep 0.5
              click_button submit
      }.to change(TempListing,:count).by(0)
      page.should have_content 'Review Your Pixi'
    end

    it "changes a pixi description" do
      expect{
	      fill_in 'Description', with: "Acoustic bass"
              click_button submit
      }.to change(TempListing,:count).by(0)
      page.should have_content 'Review Your Pixi'
      page.should have_content "Acoustic bass" 
    end

    it "adds a pixi pic" do
      expect{
              attach_file('photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
              click_button submit
      }.to change(temp_listing.pictures,:count).by(1)
      page.should have_content 'Review Your Pixi'
    end

    it "cancels build pixi", js: true do
      expect{
         click_remove_ok
      }.to change(TempListing,:count).by(0)
      page.should have_content "Pixis" 
    end

    it "cancels delete picture from listing", js: true do
      click_remove_cancel
      page.should have_content 'Build Your Pixi'
    end

    it "deletes picture from listing", js: true do
      expect{
        click_remove_ok; sleep 2
      }.to change(Picture,:count).by(-1)
      page.should have_content 'Build Your Pixi'
    end

    it "cancels build cancel", js: true do
      click_remove_cancel
      page.should have_content "Build Your Pixi" 
    end

    it "changes a pixi price" do
      expect{
              fill_in 'Price', with: nil
              click_button submit
      }.to change(TempListing,:count).by(0)
      page.should have_content 'Review Your Pixi'
    end

    it "changes a pixi quantity" do
      expect{
          select('4', :from => 'pixi_qty'); sleep 0.5
          click_button submit
      }.to change(TempListing,:count).by(0)
      page.should have_content 'Review Your Pixi'
      page.should have_content 'Quantity: 4'
    end
  end

  describe 'Reviews a Pixi' do
    let(:temp_listing) { create(:temp_listing, seller_id: user.id, status: 'new', condition_type_code: 'U', quantity: 1) }
    before :each do
      init_setup user
      visit temp_listing_path(temp_listing) 
    end

    def check_buttons model
      page.should_not have_link 'Follow', href: '#'
      check_page_selectors ['#fb-link', '#tw-link', '#pin-link'], false, true
      page.should have_link 'Edit', href: edit_temp_listing_path(model, ptype:'')
      page.should have_link 'Remove', href: temp_listing_path(model)
      page.should have_link 'Done!', href: submit_temp_listing_path(model)
      page.should_not have_button 'Next'
    end

    it 'shows content' do
      check_page_expectations ["Step 2 of 2:", "#{temp_listing.seller_name}", "ID: #{temp_listing.pixi_id}", "Posted:", "Updated:", 
       "Condition: Used", 'Acoustic Guitar'], '', false
      check_page_selectors ['#contact_content', '#comment_content'], false, true
      check_page_expectations ["Start Date:", "End Date:", "Start Time:", "End Time:", "Event Type:", "Compensation:", "Job Type:", 
       "Year:", 'VIN #:', 'Product Code:', 'Color:', 'Size:'], '', true
      check_buttons temp_listing
    end

    it 'shows event content' do
      @temp_listing = create(:temp_listing, seller_id: user.id, status: 'new', event_type_code: 'party', quantity: 1, category_id: @cat.id,
        event_start_date: Date.today+2.days, event_end_date: Date.today+3.days, event_start_time: Time.now+2.hours, event_end_time: Time.now+3.hours,
	title: 'The Event')
      visit temp_listing_path(@temp_listing) 
      check_page_expectations ["Step 2 of 2:", "#{@temp_listing.seller_name}", "ID: #{@temp_listing.pixi_id}", "Posted:", "Updated:", 
       "Date(s):", "Time(s):", "Event Type:", 'The Event'], '', false
      check_page_selectors ['#contact_content', '#comment_content'], false, true
      check_page_expectations ["Condition:", "Compensation:", "Job Type:", "Year:", 'VIN #:', 'Product Code:', 'Color:', 'Size:'], '', true
      check_buttons @temp_listing
    end

    it 'shows product content' do
      @temp_listing = create(:temp_listing, seller_id: user.id, status: 'new', condition_type_code: 'U', quantity: 1, category_id: @cat2.id,
	title: 'The Product', other_id: '123456', product_size: 'Large', color: 'Blue')
      visit temp_listing_path(@temp_listing) 
      check_page_expectations ["Start Date:", "End Date:", "Start Time:", "End Time:", "Event Type:", "Compensation:", "Job Type:", "Year:", 'VIN #:'], '', true
      check_page_selectors ['#contact_content', '#comment_content'], false, true
      check_page_expectations ["Step 2 of 2:", "#{@temp_listing.seller_name}", "ID: #{@temp_listing.pixi_id}", "Posted:", "Updated:",
        'The Product', "Condition:", 'Product Code:', 'Color:', 'Size:'], '', false
      check_buttons @temp_listing
    end

    it 'shows service content' do
      @temp_listing = create(:temp_listing, seller_id: user.id, status: 'new', category_id: @cat3.id, title: 'The Service')
      visit temp_listing_path(@temp_listing) 
      check_page_expectations ["Start Date:", "End Date:", "Start Time:", "End Time:", "Event Type:", "Compensation:", "Job Type:", "Year:", 'VIN #:',
        "Condition:", 'Product Code:', 'Color:', 'Size:', 'Quantity'], '', true
      check_page_selectors ['#contact_content', '#comment_content'], false, true
      check_page_expectations ["Step 2 of 2:", "#{@temp_listing.seller_name}", "ID: #{@temp_listing.pixi_id}", "Posted:", "Updated:",
        'The Service'], '', false
      check_buttons @temp_listing
    end

    it 'shows vehicle content' do
      @temp_listing = create(:temp_listing, seller_id: user.id, status: 'new', category_id: @cat4.id, title: 'The Vehicle', other_id: '123456',
        color: 'Blue', condition_type_code: 'U', mileage: '50000', year_built: 2001)
      visit temp_listing_path(@temp_listing) 
      check_page_expectations ["Start Date:", "End Date:", "Start Time:", "End Time:", "Event Type:", "Compensation:", "Job Type:",
        'Product Code:', 'Size:', 'Quantity:'], '', true
      check_page_selectors ['#contact_content', '#comment_content'], false, true
      check_page_expectations ["Step 2 of 2:", "#{@temp_listing.seller_name}", "ID: #{@temp_listing.pixi_id}", "Posted:", "Updated:",
        "Condition:", 'The Vehicle', 'Color:', 'Blue', 'Mileage:', '50,000', "Year:", '2001', 'VIN #:', '123456'], '', false
      check_buttons @temp_listing
    end

    it 'shows job content' do
      @temp_listing = create(:temp_listing, seller_id: user.id, status: 'new', category_id: @cat5.id, title: 'The Job', other_id: '123456',
       job_type_code: 'FT')
      visit temp_listing_path(@temp_listing) 
      check_page_expectations ["Start Date:", "End Date:", "Start Time:", "End Time:", "Event Type:", "Condition:", 
        'Product Code:', 'Size:', 'Color:', 'Mileage:', "Year:", 'VIN #:', 'Quantity'], '', true
      check_page_selectors ['#contact_content', '#comment_content'], false, true
      check_page_expectations ["Step 2 of 2:", "#{@temp_listing.seller_name}", "ID: #{@temp_listing.pixi_id}", "Posted:", "Updated:",
	"Compensation:", "Job Type:", 'The Job'], '', false
      check_buttons @temp_listing
    end

    it "cancel remove pixi", js: true do
      click_remove_cancel
      page.should have_content "Review Your Pixi" 
    end

    it "deletes a pixi", js: true do
      @loc = @site.id
      stub_const("MIN_PIXI_COUNT", 0)
      expect(MIN_PIXI_COUNT).to eq(0)
      create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id ) 
      expect{
        click_remove_ok; sleep 3;
      }.to change(TempListing,:count).by(-1)
      page.should have_content "Home" 
      page.should_not have_content temp_listing.title
    end

    it "deletes a pixi w/ local pixi home", js: true do
      @loc = @site.id
      create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id ) 
      stub_const("MIN_PIXI_COUNT", 500)
      expect(MIN_PIXI_COUNT).to eq(500)
      expect{
        click_remove_ok; sleep 3;
      }.to change(TempListing,:count).by(-1)
      page.should have_content "Pixis" 
      page.should_not have_content temp_listing.title
    end

    it "submits a pixi" do
      expect { 
	      click_link 'Done!'
	}.not_to change(TempListing, :count)
      page.should have_selector('.big_logo')
      page.should have_content temp_listing.title
      @loc = @site.id
      stub_const("MIN_PIXI_COUNT", 0)
      expect(MIN_PIXI_COUNT).to eq(0)
      page.should have_selector('#pixi-complete-btn', href: categories_path(loc: @loc))
      page.should have_selector('.img-btn', href: temp_listing_path(temp_listing))
    end

    it "submits a pixi w/ local listings home" do
      @loc = @site.id
      create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id ) 
      stub_const("MIN_PIXI_COUNT", 500)
      expect(MIN_PIXI_COUNT).to eq(500)
      expect { 
	      click_link 'Done!'
	}.not_to change(TempListing, :count)
      page.should have_selector('.big_logo')
      page.should have_content temp_listing.title
      page.should have_selector('#pixi-complete-btn', href: local_listings_path(loc: @loc))
      page.should have_selector('.img-btn', href: temp_listing_path(temp_listing))
    end

    it "goes back to build a pixi" do
      expect { 
	      click_link 'Edit'
	}.not_to change(TempListing, :count)
      page.should have_content "Build Your Pixi" 
    end
  end

  describe 'Reviews premium pixi' do
    let(:category) { create :category, name: 'Jobs', pixi_type: 'premium' }
    let(:temp_listing) { create(:temp_listing, seller_id: user.id, status: 'new', category_id: category.id) }
    before :each do
      init_setup user
      visit temp_listing_path(temp_listing) 
    end

    it 'shows content' do
      page.should have_content "Step 2 of 2"
      page.should_not have_link 'Done!', href: resubmit_temp_listing_path(temp_listing)
      page.should have_link 'Done!', href: submit_temp_listing_path(temp_listing)
      page.should_not have_button 'Next'
    end

    it "submits a pixi" do
      expect { 
	click_link "Done"
      }.not_to change(TempListing, :count)
      expect(TempListing.get_by_status('pending').count).to eq 1
      page.should have_content "Pixi Submitted!" 
    end
  end

  describe 'Reviews active Pixi', js: true do
    let(:temp_listing) { create(:temp_listing, seller_id: user.id, status: 'edit') }
    before :each do
      init_setup user
      visit temp_listing_path(temp_listing) 
    end

    it 'shows content' do
      page.should have_link 'Done!', href: submit_temp_listing_path(temp_listing)
      page.should_not have_button 'Next'
    end

    it "cancels review of active pixi" do
      click_cancel_cancel
      page.should have_content "Review Your Pixi" 
    end

    it "cancels pixi review" do
      click_cancel_ok; sleep 2
      page.should have_content "Pixis" 
    end
  end

  describe "Create PixiPosted Pixis" do
    let(:temp_listing) { build(:temp_listing) }

    before(:each) do
      init_setup pixter
      visit new_temp_listing_path(pixan_id: @user)
    end

    it 'shows content' do
      build_page_content
      page.should have_content('Seller')
      page.should have_selector('#seller_id')
    end

    it "Adds a new pixi_post listing w price", js: true do
      fill_autocomplete 'slr_name', with: seller.first_name
      select('Used', :from => 'cond-type-code')
      add_pixi
      expect(TempListing.last.pixan_id).to eq pixter.id
    end	      
  end

  describe "Create Pixter Posted Pixis" do
    let(:temp_listing) { build(:temp_listing) }

    before(:each) do
      init_setup pixter
      visit new_temp_listing_path(pixan_id: @user, ptype: 'bus')
    end

    it 'shows content' do
      build_page_content
      page.should have_content('Seller')
      page.should have_selector('#seller_id')
    end

    it "Adds a new pixi_post listing w price", js: true do
      fill_autocomplete 'slr_name', with: business_user.business_name
      select('Used', :from => 'cond-type-code')
      select('Pickup', :from => 'fulfill_type')
      add_pixi
      expect(TempListing.last.pixan_id).to be_nil
    end	      
  end

  describe "Create Business Posted Pixis" do
    it "shows business fields" do
      init_setup business_user
      business_user.bank_accounts.create(FactoryGirl.attributes_for :bank_account)
      visit new_temp_listing_path(ptype: 'bus')
      page.should have_content('Delivery Type')
      page.should have_content('Sales Tax')
      page.should have_content('Est Ship Amt')
      page.should have_content('Buy Now')
    end

    it "requires ship amount", js: true do
      init_setup business_user
      business_user.bank_accounts.create(FactoryGirl.attributes_for :bank_account)
      visit new_temp_listing_path(ptype: 'bus')
      select('Ship', :from => 'fulfill_type')
      find_field('ship_cost_box')[:required].should == 'true'
    end
  end

  describe "Edit Business Posted Pixis" do
    before :each do
      attr = {"seller_id"=>"#{user.id}", "title"=>"Dilworth Leather Loveseat", "category_id"=>"31", "condition_type_code"=>"ULN", 
      "job_type_code"=>"", "event_type_code"=>"", "site_id"=>"9904", "price"=>"300", "quantity"=>"1", "year_built"=>"", "compensation"=>"", 
      "event_start_date"=>"", "event_end_date"=>"", "car_id"=>"", "car_color"=>"","mileage"=>"", "item_color"=>"", "product_size"=>"", "item_id"=>"", 
      "description"=>"great condition", "start_date"=>"2015-04-13 19:58:11 -0700", "status"=>"new", "post_ip"=>"127.0.0.1",
      "pictures_attributes"=>{"0"=>{"direct_upload_url"=>"Dilworth-loveseat-Leather-22.jpg","photo_file_name"=>"Dilworth-loveseat-Leather-22.jpg", 
      "photo_file_path"=>"/uploads/1428981009986-dla2y3o9mjejnhfr-3c45659dc6c50163f3b8048e5b81e979/Dilworth-loveseat-Leather-22.jpg", 
      "photo_file_size"=>"1061500", "photo_content_type"=>"image/jpeg"}} }
      @temp = TempListing.new attr
      @temp.save
      init_setup admin
      visit edit_temp_listing_path(@temp, ptype: 'bus')
    end

    it "Changes a pixi title" do
      expect{
	      fill_in 'Title', with: "Leather Loveseat for Sale"
              click_button submit
      }.to change(TempListing,:count).by(0)
      page.should have_content 'Leather Loveseat For Sale'
      page.should have_content 'Review Your Pixi'
      expect(@temp.reload.seller_id).to eq user.id
    end

    it "adds a pixi pic" do
      expect{
              attach_file('photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
              click_button submit
      }.to change(@temp.pictures,:count).by(1)
      page.should have_content 'Review Your Pixi'
      expect(@temp.reload.seller_id).to eq user.id
    end

    it "assigns default values from preferences" do
      business_user = create :business_user
      business_user.bank_accounts.create(FactoryGirl.attributes_for :bank_account)
      create :fulfillment_type, code: 'SHP'
      pref = business_user.preferences.first
      pref.ship_amt = 5.0
      pref.sales_tax = 10.0
      pref.fulfillment_type_code = 'SHP'
      pref.save
      init_setup business_user
      visit edit_temp_listing_path(@temp, ptype: 'bus')
      page.should have_content('Delivery Type')
      page.should have_xpath("//option[@value='#{pref.fulfillment_type_code}' and @selected='selected']")
      page.should have_content('Est Ship Amt')
      page.should have_xpath("//input[@value='#{pref.ship_amt.to_s << '0'}']")
      page.should have_content('Sales Tax')
      page.should have_xpath("//input[@value='#{pref.sales_tax}']")
      page.should have_content("Buy Now")
      page.should have_xpath("//input[@id='temp_listing_buy_now_flg' and @checked='checked']")
    end
  end

  describe "Create Default Site Posted Pixis" do
    let(:temp_listing) { build(:temp_listing) }
    let(:loc) {create :site, site_type_code: 'pub'}

    before(:each) do
      init_setup user
      visit new_temp_listing_path(loc: loc.id)
    end

    it "Adds a new listing w price", js: true do
      select('Used', :from => 'cond-type-code')
      add_pixi 'Foo Bar', true, false, "Guitar for Sale", false
      expect(TempListing.last.site_id).to eq loc.id
    end	      
  end
end
