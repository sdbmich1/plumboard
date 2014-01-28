require 'spec_helper'

describe "Listings", :type => :feature do
  subject { page }
  
  let(:user) { FactoryGirl.create(:contact_user) }
  let(:site) { FactoryGirl.create :site }
  let(:site_contact) { site.contacts.create FactoryGirl.attributes_for(:contact) }
  let(:temp_listing) { FactoryGirl.create(:temp_listing, title: "Guitar", description: "Lessons", seller_id: user.id ) }
  let(:listing) { FactoryGirl.create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id, pixi_id: temp_listing.pixi_id,
    site_id: site.id) }

  describe "Contact Owner" do 
    let(:pixi_user) { FactoryGirl.create(:pixi_user, email: 'jdoe2@pixitest.com') }

    before(:each) do
      login_as(pixi_user, :scope => :user, :run_callbacks => false)
      @user = pixi_user
      visit listing_path(listing) 
    end
     
    it { should have_content listing.nice_title }
    it { should have_content "Posted By: #{listing.seller_name}" }
    it { should have_link 'Follow', href: '#' }
    it { should have_link listing.site_name, href: local_listings_path(loc: listing.site_id) }
    it { should have_link listing.category_name, href: category_listings_path(cid: listing.category_id, loc: listing.site_id) }
    it { should_not have_link 'Back', href: listings_path }
    it { should_not have_link 'Remove', href: listing_path(listing) }
    it { should_not have_link 'Edit', href: edit_temp_listing_path(listing) }
    it { should have_content "ID: #{listing.pixi_id}" }
    it { should have_content "Posted: #{get_local_time(listing.start_date)}" }
    it { should have_content "Updated: #{get_local_time(listing.updated_at)}" }
    it { should_not have_content "Start Date: #{short_date(listing.event_start_date)}" }
    it { should_not have_content "End Date: #{short_date(listing.event_end_date)}" }
    it { should_not have_content "Start Time: #{short_time(listing.event_start_time)}" }
    it { should_not have_content "End Time: #{short_time(listing.event_end_time)}" }
    it { should have_content "Price: " }
    it { should_not have_content "Compensation: #{(listing.compensation)}" }

    it "Contacts a seller", js: true do
      expect{
      	  fill_in 'contact_content', with: "I'm interested in this pixi. Please contact me.\n"
	  sleep 3
      }.to change(Post,:count).by(1)

      page.should have_content listing.nice_title
    end
     
    it "does not contact a seller", js: true do
      expect{
	  fill_in 'contact_content', with: "\n"
      }.not_to change(Post,:count).by(1)

      page.should have_content "Content can't be blank"
    end

    it "clicks on site" do
      click_link listing.site_name
      page.should have_content 'Pixis'
      page.should have_content listing.nice_title
    end

    it "clicks on category by site" do
      click_link listing.category_name
      page.should have_content 'Pixis'
      page.should have_content listing.nice_title
    end
  end

  describe "View Event Pixi" do 
    let(:category) { FactoryGirl.create :category, name: 'Event' }
    let(:listing) { FactoryGirl.create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id, pixi_id: temp_listing.pixi_id, 
      category_id: category.id, event_start_date: Date.tomorrow, event_end_date: Date.tomorrow, event_start_time: Time.now+2.hours, 
      event_end_time: Time.now+3.hours ) }
    let(:pixi_user) { FactoryGirl.create(:pixi_user, email: 'jdoe2@pixitest.com') }

    before(:each) do
      login_as(pixi_user, :scope => :user, :run_callbacks => false)
      @user = pixi_user
      visit listing_path(listing) 
    end
     
    it { should have_content "Start Date: #{short_date(listing.event_start_date)}" }
    it { should have_content "End Date: #{short_date(listing.event_end_date)}" }
    it { should have_content "Start Time: #{short_time(listing.event_start_time)}" }
    it { should have_content "End Time: #{short_time(listing.event_end_time)}" }
    it { should have_content "Price: " }
    it { should_not have_content "Compensation: #{(listing.compensation)}" }

    it "clicks on a location" do
      click_link listing.site_name

      page.should have_content "Pixis" 
      page.should have_content listing.nice_title
    end

    it "clicks on a category" do
      click_link listing.category_name

      page.should have_content "Pixis" 
      page.should have_content listing.nice_title
      page.should have_content listing.category_name
    end

  end

  describe "View Compensation Pixi" do 
    let(:category) { FactoryGirl.create :category, name: 'Gigs' }
    let(:listing) { FactoryGirl.create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id, pixi_id: temp_listing.pixi_id, 
      category_id: category.id, compensation: 'Salary + Equity', price: nil) }
    let(:pixi_user) { FactoryGirl.create(:pixi_user, email: 'jdoe2@pixitest.com') }

    before(:each) do
      login_as(pixi_user, :scope => :user, :run_callbacks => false)
      @user = pixi_user
      visit listing_path(listing) 
    end
     
    it { should_not have_content "Start Date: #{short_date(listing.event_start_date)}" }
    it { should_not have_content "End Date: #{short_date(listing.event_end_date)}" }
    it { should_not have_content "Start Time: #{short_time(listing.event_start_time)}" }
    it { should_not have_content "End Time: #{short_time(listing.event_end_time)}" }
    it { should_not have_content "Price: #{(listing.price)}" }
    it { should have_content "Compensation: #{(listing.compensation)}" }
  end

  describe "Owner-viewed Pixi" do 

    before(:each) do
      login_as(user, :scope => :user, :run_callbacks => false)
      @user = user
      visit listing_path(listing) 
    end

    it { should have_content "Posted By: #{listing.seller_name}" }
    it { should_not have_selector('#contact_content') }
    it { should_not have_selector('#comment_content') }
    it { should_not have_link 'Follow', href: '#' }
    # it { should_not have_link 'Follow', href: '#' }
    it { should have_content "Comments (#{listing.comments.size})" }
    it { should have_link 'Back', href: listings_path }
    it { should have_link 'Remove', href: listing_path(listing) }
    it { should have_link 'Edit', href: edit_temp_listing_path(listing) }
  end

  describe "Add Comments" do 
    let(:pixi_user) { FactoryGirl.create(:pixi_user, first_name: 'Tom', last_name: 'Davis', email: 'tdavis@pixitext.com') }

    before(:each) do
      login_as(pixi_user, :scope => :user, :run_callbacks => false)
      @user = pixi_user
      visit listing_path(listing) 
    end

    it { should have_content "No comments found." }
    it { should have_content "Comments (#{listing.comments.size})" }
     
    it "adds a comment", js: true do
      expect{
      	  fill_in 'comment_content', with: "Great pixi. I highly recommend it.\n" 
	  sleep 3
      }.to change(Comment,:count).by(1)

      page.should have_content "Great pixi. I highly recommend it." 
      page.should have_content "Comments (#{listing.comments.size})"
    end
     
    it "does not add a comment", js: true do
      expect{
	  fill_in 'comment_content', with: "\n"
      }.not_to change(Comment,:count).by(1)

      page.should have_content "Content can't be blank"
    end
  end

  describe "pagination" do
    let(:pixi_user) { FactoryGirl.create(:pixi_user, first_name: 'Tom', last_name: 'Davis', email: 'tdavis@pixitext.com') }
    before(:all) { 10.times { listing.comments.create FactoryGirl.attributes_for(:comment, user_id: pixi_user.id) } }

    before(:each) do
      login_as(pixi_user, :scope => :user, :run_callbacks => false)
      @user = pixi_user
      visit listing_path(listing) 
    end

    it { should have_selector('div.pagination') }

    it "should list each comment" do
      listing.comments.paginate(page: 1).each do |comment|
        page.should have_selector('li', text: comment.summary)
      end
    end
  end

  describe "Check Pixis" do 

    before(:each) do
      login_as(user, :scope => :user, :run_callbacks => false)
      user.confirm!
      @user = user
    end

    describe "Review Pixis" do 
      before { visit listing_path(listing) }

      it "Deletes a pixi" do
        expect{
              click_on 'Remove'
        }.to change(Listing,:count).by(-1)

        page.should have_content "Pixis" 
        page.should_not have_content "Guitar Lessons" 
      end

      describe "Edits active pixi" do
        before :each do
          click_link 'Edit'
	end

        it { should have_content("Build Pixi") }

        it "adds a pixi pic" do
          expect{
              attach_file('photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
              click_button 'Next'; sleep 2
          }.to change(Picture,:count).by(1)

          page.should have_content 'Review Your Pixi'
        end
      end

      it "Returns to pixi list" do
        click_link 'Back'
        page.should have_content("Pixis")
      end

      it "Views a pixi" do
        page.should have_selector('title', text: listing.nice_title) 
      end
    end

    describe "GET /listings" do  
      let(:temp_listing) { FactoryGirl.create(:temp_listing, title: "Guitar", description: "Lessons", seller_id: @user.id ) }
      let(:listings) { 30.times { FactoryGirl.create(:listing, seller_id: @user.id) } }

      before do
        @site = FactoryGirl.create :site, name: 'Pixi Tech'
	@category = FactoryGirl.create :category
        FactoryGirl.create(:listing, title: "HP Printer J4580", description: "printer", seller_id: @user.id, site_id: @site.id, 
	  category_id: @category.id) 
        @listing = FactoryGirl.create(:listing, title: "Guitar", description: "Lessons", seller_id: @user.id, pixi_id: temp_listing.pixi_id,
	  category_id: @category.id) 
	@category1 = FactoryGirl.create :category, name: 'Gigs'
	@category2 = FactoryGirl.create :category, name: 'Automotive'
	@category3 = FactoryGirl.create :category, name: 'Furniture'
	@category4 = FactoryGirl.create :category, name: 'Books'
        @listing1 = FactoryGirl.create(:listing, title: "Intern", description: "Unpaid job", seller_id: @user.id, category_id: @category1.id, 
	  site_id: @site.id) 
        @listing2 = FactoryGirl.create(:listing, title: "Buick Regal", description: "used car", seller_id: @user.id, category_id: @category2.id) 
        @listing3 = FactoryGirl.create(:listing, title: "Sofa", description: "used couch", seller_id: @user.id, category_id: @category3.id) 
        @listing4 = FactoryGirl.create(:listing, title: "Calc 201", description: "text book", seller_id: @user.id, category_id: @category4.id) 
        visit listings_path 
      end
      
      it { should have_link 'Recent', href: listings_path }
      # it { should have_link 'Following', href: '#' }
      # it { should have_link 'Map', href: '#' }
      # it { should have_link 'Categories', href: categories_path }
      it { should have_content('Pixis') }
      
      it "scrolls listings", js: true do 
        page.execute_script "window.scrollBy(0,1000)"
      end

      it "searches for a listing", js: true do
        fill_in 'search', with: 'guitar'
	click_on 'submit-btn'
        page.should_not have_content 'HP Printer J4580'
        page.should have_content @listing.title
      end

      it "selects a site", js: true do
        select(@site.name, :from => 'site_id')
        page.should have_content 'HP Printer J4580'

	click_link 'Recent'
        page.should have_content @listing.title
      end

      it "selects categories", js: true do
        select(@category.name_title, :from => 'category_id')
        page.should have_content @category.name_title
        page.should have_content 'HP Printer J4580'
        page.should_not have_content @listing1.title
        page.should have_content @listing.title
	# click_link 'Categories'
        # page.should have_content @category.name_title
        # page.should have_content "(#{@category.active_pixis_by_site(@site.id).size})" 
      end
    end  

    describe "seller listings page" do
      let(:listings) { 30.times { FactoryGirl.create(:listing, seller_id: @user.id) } }
      before { visit seller_listings_path }
      
      it { should have_content('My Pixis') }

      describe "pagination" do
        it "should list each listing" do
          @user.pixis.paginate(page: 1).each do |listing|
            page.should have_selector('td', text: listing.title)
          end
        end
      end
    end
  end

end
