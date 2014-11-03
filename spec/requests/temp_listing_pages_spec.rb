require 'spec_helper'

feature "TempListings" do
  subject { page }
  let(:user) { FactoryGirl.create(:pixi_user) }
  let(:submit) { "Next" }

  before(:each) do
    init_setup user
    create_sites
  end

  def create_sites
    @site = FactoryGirl.create :site, name: 'Santa Clara University'
    @site1 = FactoryGirl.create :site
    FactoryGirl.create :site, name: 'Stanford University'
    FactoryGirl.create :site, name: 'San Francisco - Nob Hill'
  end

    def add_data
      fill_in 'Title', with: "Guitar for Sale"
      fill_in 'site_name', with: "Stanford University\n"
      set_site_id @site.id; sleep 1.5
      select_category 'Foo Bar'
      fill_in 'Description', with: "Guitar for Sale"
    end

  def add_data_w_photo
    # script = "$('input[type=file]').show();"
    # page.driver.browser.execute_script(script)
    # stub_paperclip_attachment(Picture, :picture)
    attach_file('photo', "#{Rails.root}/spec/fixtures/photo.jpg")
    add_data
  end

  def click_cancel_ok
    click_link 'Cancel'
    page.driver.browser.switch_to.alert.accept
  end

  def click_cancel_cancel
    click_link 'Cancel'
    page.driver.browser.switch_to.alert.dismiss
  end

  def click_remove_ok
    click_link 'Remove'
    page.driver.browser.switch_to.alert.accept
  end

  def click_remove_cancel
    click_link 'Remove'
    page.driver.browser.switch_to.alert.dismiss
  end

  def set_site_id sid
    page.execute_script %Q{ $('#site_id').val("#{sid}") }
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

  describe "Manage Temp Pixis" do
    let(:temp_listing) { FactoryGirl.build(:temp_listing) }

    before(:each) do
      FactoryGirl.create :category 
      FactoryGirl.create :category, name: 'Automotive'
      FactoryGirl.create :category, name: 'Event'
      FactoryGirl.create :category, name: 'Jobs'
      visit new_temp_listing_path
    end

    it 'shows content' do
      page.should have_content "Build Your Pixi"
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

    def event_data sdt, edt
      attach_file('photo', "#{Rails.root}/spec/fixtures/photo.jpg")
      fill_in 'Title', with: "Guitar for Sale"
      set_site_id @site.id; sleep 0.5
      select_category 'Event'
      fill_in 'Description', with: "Guitar for Sale"
      fill_in 'start-date', with: sdt
      fill_in 'end-date', with: edt
    end

    describe "Create with invalid information", js: true do
      it "should not create a listing" do
        expect { click_button submit }.not_to change(TempListing, :count)
	page.should have_content "Title can't be blank"
      end

      it "does not create a listing w/o site" do
        expect { 
          fill_in 'Title', with: "Guitar for Sale"
          fill_in 'Price', with: "150.00"
          select_category 'Foo Bar'
          fill_in 'Description', with: "Guitar for Sale"
          attach_file('photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
	  click_button submit }.not_to change(TempListing, :count)
	  page.should have_content "Site can't be blank"
      end

      it "does not create a listing w/o category" do
        expect { 
          fill_in 'Title', with: "Guitar for Sale"
          fill_in 'Price', with: "150.00"
          set_site_id @site.id; sleep 0.5
          fill_in 'Description', with: "Guitar for Sale"
          attach_file('photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
	  click_button submit }.not_to change(TempListing, :count)
	  page.should have_content "Category can't be blank"
      end

      it "does not create a listing w/o description" do
        expect { 
          fill_in 'Title', with: "Guitar for Sale"
          fill_in 'Price', with: "150.00"
          set_site_id @site.id; sleep 0.5
          select_category 'Foo Bar'
          attach_file('photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
	  click_button submit }.not_to change(TempListing, :count)
	  page.should have_content "Description can't be blank"
      end

      it "does not create a listing w/o start date" do
        expect { 
          fill_in 'Title', with: "Guitar for Sale"
          fill_in 'Price', with: "150.00"
          set_site_id @site.id; sleep 0.5
          select_category 'Foo Bar'
          attach_file('photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
          fill_in 'Description', with: "Guitar for Sale"
	  click_button submit }.not_to change(TempListing, :count)
	  page.should have_content "Start Date is not a valid date"
      end

      it "does not create a listing w/ bad start date" do
        expect { 
	  event_data "30/30/2456", Date.today().strftime('%m/%d/%Y')
	  click_button submit }.not_to change(TempListing, :count)
	  page.should have_content "Start Date is not a valid date"
      end

      it "does not create a listing w/ invalid start date" do
        expect { 
	  event_data Date.yesterday.strftime('%m/%d/%Y'), Date.today().strftime('%m/%d/%Y')
	  click_button submit }.not_to change(TempListing, :count)
	  page.should have_content "Start Date must be on or after "
      end

      it "does not create a listing w/o end date" do
        expect { 
	  event_data Date.today().strftime('%m/%d/%Y'), nil
	  click_button submit }.not_to change(TempListing, :count)
	  page.should have_content "End Date is not a valid date"
      end

      it "does not create a listing w/ bad end date" do
        expect { 
	  event_data Date.today().strftime('%m/%d/%Y'), "30/30/2456"
	  click_button submit }.not_to change(TempListing, :count)
	  page.should have_content "End Date is not a valid date"
      end

      it "does not create a listing w/ invalid end date" do
        expect { 
	  event_data Date.today().strftime('%m/%d/%Y'), Date.yesterday.strftime('%m/%d/%Y') 
	  click_button submit }.not_to change(TempListing, :count)
	  page.should have_content "End Date must be on or after"
      end

      it "should not create a listing w/o photo" do
        expect { 
	  add_data
	  click_button submit }.not_to change(TempListing, :count)
	  page.should have_content "Must have at least one picture"
      end
    end

    describe "Create with valid information", js:true do
      it "Adds a new listing w/o price" do
        expect{
	  add_data_w_photo
	  click_button submit; sleep 3
          page.should have_content 'Review Your Pixi'
          page.should have_content "Guitar for Sale" 
	}.to change(TempListing,:count).by(1)
      end	      

      it "Adds a new listing w price" do
        expect{
	  add_data_w_photo
          fill_in 'Price', with: "150.00"
	  click_button submit; sleep 3
	}.to change(TempListing,:count).by(1)
        page.should have_content "Guitar for Sale" 
        page.should have_content 'Review Your Pixi'
        page.should have_content "Price: $150.00" 
      end	      

      it "Adds a new listing w compensation" do
        expect{
		add_data_w_photo
                select('Jobs', :from => 'temp_listing_category_id')
                select('Full-Time', :from => 'temp_listing_job_type_code')
                fill_in 'salary', with: "Competitive"
	        click_button submit; sleep 3
	      }.to change(TempListing,:count).by(1)
        page.should have_content "Guitar for Sale" 
        page.should have_content 'Review Your Pixi'
        page.should have_content "Job Type: Full-Time" 
        page.should have_content "Compensation: Competitive" 
        page.should_not have_content "Price:" 
      end	      

      it "Adds a new listing w year" do
        expect{
		add_data_w_photo
                fill_in 'Title', with: "Buick Regal for sale"
                select('Automotive', :from => 'temp_listing_category_id')
                select('2001', :from => 'yr_built')
	        click_button submit
	      }.to change(TempListing,:count).by(1)
        page.should have_content "Buick Regal for sale" 
        page.should have_content 'Review Your Pixi'
        page.should have_content "Price:" 
        page.should have_content "Year: 2001" 
      end	      

      it "Adds a new listing w event" do
        expect{
		add_data_w_photo
                set_site_id @site.id; sleep 0.5
                fill_in 'Price', with: "150.00"
                select('Event', :from => 'temp_listing_category_id')
                fill_in 'start-date', with: Date.today().strftime('%m/%d/%Y')
                fill_in 'end-date', with: Date.today().strftime('%m/%d/%Y')
		select('5:00 PM', :from => 'start-time')
		select('10:00 PM', :from => 'end-time')
	        click_button submit
	}.to change(TempListing,:count).by(1)
        page.should have_content "Guitar for Sale" 
        page.should have_content 'Review Your Pixi'
        page.should have_content "Start Date: "
        page.should have_content "End Date: "
        page.should have_content "Start Time: "
        page.should have_content "End Time: "
        page.should_not have_content "Compensation: Competitive" 
        page.should have_content "Price:" 
      end	      
    end	      
  end

  describe "Edit Invalid Temp Pixi" do 
    let(:temp_listing) { FactoryGirl.create(:temp_listing) }
    before { visit edit_temp_listing_path(temp_listing) }

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
      page.should have_content "Title can't be blank"
      page.should have_content 'Build Pixi'
    end

    it "empty description should not change a listing" do
      expect { 
	      fill_in 'Description', with: nil
	      click_button submit 
	}.not_to change(TempListing, :count)
      page.should have_content "Description can't be blank"
      page.should have_content 'Build Pixi'
    end

    it "invalid price should not change a listing" do
      expect { 
	      fill_in 'Price', with: '$500'
	      click_button submit 
	}.not_to change(TempListing, :count)
      page.should have_content 'Build Pixi'
      page.should have_content "Price is not a number"
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
    let(:temp_listing) { FactoryGirl.create(:temp_listing_with_pictures) }
    before do
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
      page.should_not have_content temp_listing.nice_title
      page.should have_content 'Guitar For Sale'
      page.should have_content 'Review Your Pixi'
    end

    it "Changes a pixi site", js: true do
      page.should have_css('#site_id', :visible => false)
      expect{
              set_site_id @site.id; sleep 0.5
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
      page.should have_content 'Build Pixi'
    end

    it "deletes picture from listing", js: true do
      expect{
        click_remove_ok; sleep 2
      }.to change(Picture,:count).by(-1)
      page.should have_content 'Build Pixi'
    end

    it "cancels build cancel", js: true do
      click_remove_cancel
      page.should have_content "Build Pixi" 
    end

    it "changes a pixi price" do
      expect{
              fill_in 'Price', with: nil
              click_button submit
      }.to change(TempListing,:count).by(0)
      page.should have_content 'Review Your Pixi'
    end
  end

  describe 'Reviews a Pixi' do
    let(:temp_listing) { FactoryGirl.create(:temp_listing, seller_id: user.id, status: 'new') }
    before { visit temp_listing_path(temp_listing) }

    it 'shows content' do
      page.should have_content "Step 2 of 2"
      page.should have_content "Posted By: #{temp_listing.seller_name}"
      page.should_not have_selector('#contact_content')
      page.should_not have_selector('#comment_content')
      page.should_not have_link 'Follow', href: '#'
      page.should have_link 'Edit', href: edit_temp_listing_path(temp_listing)
      page.should have_link 'Remove', href: temp_listing_path(temp_listing)
      page.should have_link 'Done!', href: submit_temp_listing_path(temp_listing)
      page.should_not have_button 'Next'
      page.should have_content "ID: #{temp_listing.pixi_id}"
      page.should have_content "Posted: #{get_local_time(temp_listing.start_date)}"
      page.should have_content "Updated: #{get_local_time(temp_listing.updated_at)}"
      page.should have_content 'Acoustic Guitar'
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
    end

    it "goes back to build a pixi" do
      expect { 
	      click_link 'Edit'
	}.not_to change(TempListing, :count)
      page.should have_content "Build Pixi" 
    end
  end

  describe 'Reviews premium pixi' do
    let(:category) { FactoryGirl.create :category, name: 'Jobs', pixi_type: 'premium' }
    let(:temp_listing) { FactoryGirl.create(:temp_listing, seller_id: user.id, status: 'new', category_id: category.id) }
    before { visit temp_listing_path(temp_listing) }

    it 'shows content' do
      page.should have_content "Step 2 of 3"
      page.should_not have_link 'Done!', href: resubmit_temp_listing_path(temp_listing)
      page.should_not have_link 'Done!', href: submit_temp_listing_path(temp_listing)
      page.should have_button 'Next'
    end

    it "submits a pixi" do
      expect { 
	      click_button submit
	}.not_to change(TempListing, :count)

      page.should have_content "Submit Your Pixi" 
    end
  end

  describe 'Reviews active Pixi', js: true do
    let(:temp_listing) { FactoryGirl.create(:temp_listing, seller_id: user.id, status: 'edit') }
    before { visit temp_listing_path(temp_listing) }

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
end
