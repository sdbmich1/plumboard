require 'spec_helper'

describe "Listings", :type => :feature do
  subject { page }
  
  let(:user) { FactoryGirl.create(:contact_user) }
  let(:site) { FactoryGirl.create :site }
  let(:site_contact) { site.contacts.create FactoryGirl.attributes_for(:contact) }
  let(:temp_listing) { FactoryGirl.create(:temp_listing, title: "Guitar", description: "Lessons", seller_id: user.id ) }
  let(:listing) { FactoryGirl.create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id, pixi_id: temp_listing.pixi_id,
    site_id: site.id) }

  def init_setup usr
    login_as(usr, :scope => :user, :run_callbacks => false)
    @user = usr
  end

  def set_site_id
    page.execute_script %Q{ $('#site_id').val("#{@site.id}") }
  end

  describe "Contact Owner" do 
    before(:each) do
      pixi_user = FactoryGirl.create(:pixi_user) 
      init_setup pixi_user
      visit listing_path(listing) 
    end
     
    it { should have_content listing.nice_title }
    it { should have_content "Posted By: #{listing.seller_name}" }
    it { should have_selector('.rateit') }
    it { should have_link 'Want', href: '#' }
    it { find_link('Cool').visible? }
    it { should_not have_link 'Uncool' }
    it { should have_link 'Save' }
    it { should_not have_link 'Unsave' }
    it { should have_selector('#fb-link') }
    it { should have_selector('#tw-link') }
    it { should have_selector('#pin-link') }
    it { should_not have_link 'Follow', href: '#' }
    it { should have_link listing.site_name, href: local_listings_path(loc: listing.site_id) }
    it { should have_link listing.category_name, href: category_listings_path(cid: listing.category_id, loc: listing.site_id) }
    it { should_not have_link 'Back', href: listings_path }
    it { should_not have_link 'Remove', href: listing_path(listing) }
    it { should_not have_link 'Edit', href: edit_temp_listing_path(listing) }
    it { should have_content "ID: #{listing.pixi_id}" }
    it { should have_content "Posted: #{listing.get_local_time(listing.start_date)}" }
    it { should have_content "Updated: #{listing.get_local_time(listing.updated_at)}" }
    it { should_not have_content "Start Date: #{short_date(listing.event_start_date)}" }
    it { should_not have_content "End Date: #{short_date(listing.event_end_date)}" }
    it { should_not have_content "Start Time: #{short_time(listing.event_start_time)}" }
    it { should_not have_content "End Time: #{short_time(listing.event_end_time)}" }
    it { should have_content "Price: " }
    it { should_not have_content "Compensation: #{(listing.compensation)}" }

    it "Contacts a seller", js: true do
      expect{
          page.find('#want-btn').click
	  page.execute_script("$('#post_form').toggle();")
          page.should have_selector('#contact_content', visible: true) 
      	  fill_in 'contact_content', with: "I'm interested in this pixi. Please contact me.\n"
	  sleep 3
          page.should_not have_link 'Want'
          page.should have_content 'Want'
      }.to change(Post,:count).by(1)

      page.should have_content listing.nice_title
    end
     
    it "does not contact a seller", js: true do
      expect{
          page.find('#want-btn').click
	  page.execute_script("$('#post_form').toggle();")
          page.should have_selector('#contact_content', visible: true) 
	  fill_in 'contact_content', with: "\n"
          page.should have_link 'Want'
      }.not_to change(Post,:count).by(1)

      page.should have_content "Content can't be blank"
    end

    it "clicks on Cool", js: true do
      expect{
          page.find('#cool-btn').click
	  sleep 3
          page.should have_link 'Uncool'
          page.should_not have_link 'Cool'
      }.to change(PixiLike,:count).by(1)

      page.should have_content listing.nice_title
    end

    it "clicks on Save", js: true do
      expect{
          page.find('#save-btn').click
	  sleep 3
          page.should have_link 'Unsave'
      }.to change(SavedListing,:count).by(1)

      page.should have_content listing.nice_title
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

  describe "View Pixi w/ buyer flags set" do 
    before(:each) do
      pixi_user = FactoryGirl.create(:pixi_user) 
      init_setup pixi_user
      @user.pixi_likes.create FactoryGirl.attributes_for :pixi_like, pixi_id: listing.pixi_id
      @user.saved_listings.create FactoryGirl.attributes_for :saved_listing, pixi_id: listing.pixi_id
      @user.posts.create FactoryGirl.attributes_for :post, pixi_id: listing.pixi_id, recipient_id: user.id
      visit listing_path(listing) 
    end

    it { should_not have_link 'Want', href: '#' }
    it { should have_content 'Want' }
    it { find_link('Uncool').visible? }
    it { should_not have_link 'Cool' }
    it { should have_link 'Unsave' }

    it "clicks on Uncool", js: true do
      expect{
          page.find('#cool-btn').click
	  sleep 3
          page.should_not have_link 'Uncool'
          page.should have_link 'Cool'
      }.to change(PixiLike,:count).by(-1)

      page.should have_content listing.nice_title
    end

    it "clicks on Unsave", js: true do
      expect{
          page.find('#save-btn').click
	  sleep 3
          page.should have_link 'Save'
      }.to change(SavedListing,:count).by(-1)

      page.should have_content listing.nice_title
    end
  end

  describe "View Event Pixi" do 
    let(:category) { FactoryGirl.create :category, name: 'Event' }
    let(:listing) { FactoryGirl.create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id, pixi_id: temp_listing.pixi_id, 
      category_id: category.id, event_start_date: Date.tomorrow, event_end_date: Date.tomorrow, event_start_time: Time.now+2.hours, 
      event_end_time: Time.now+3.hours ) }

    before(:each) do
      pixi_user = FactoryGirl.create(:pixi_user) 
      init_setup pixi_user
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

    before(:each) do
      pixi_user = FactoryGirl.create(:pixi_user) 
      init_setup pixi_user
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
      init_setup user
      visit listing_path(listing) 
    end

    it { should have_content "Posted By: #{listing.seller_name}" }
    it { should_not have_selector('#contact_content') }
    it { should_not have_selector('#comment_content') }
    it { should_not have_selector('#want-btn') }
    it { should_not have_selector('#cool-btn') }
    it { should_not have_selector('#save-btn') }
    it { should_not have_selector('#fb-link') }
    it { should_not have_selector('#tw-link') }
    it { should_not have_selector('#pin-link') }
    it { should_not have_link 'Follow', href: '#' }
    it { should have_content "Comments (#{listing.comments.size})" }
    it { should_not have_link 'Cancel', href: root_path }
    it { should have_link 'Remove', href: listing_path(listing) }
    it { should have_link 'Edit', href: edit_temp_listing_path(listing) }
  end

  describe "Add Comments" do 
    before(:each) do
      pixi_user = FactoryGirl.create(:pixi_user) 
      init_setup pixi_user
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
    before(:each) do
      pixi_user = FactoryGirl.create(:pixi_user) 
      init_setup pixi_user
      10.times { listing.comments.create FactoryGirl.attributes_for(:comment, user_id: pixi_user.id) } 
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
      init_setup user
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
    end

    describe "GET /category" do  
      let(:category) { FactoryGirl.create :category }
      let(:site) { FactoryGirl.create :site }
      let(:listings) { 10.times { FactoryGirl.create(:listing, seller_id: @user.id, category_id: category.id, site_id: site.id) } }

      before(:each) do
        FactoryGirl.create(:listing, title: "Guitar", seller_id: @user.id, site_id: site.id, category_id: category.id) 
        visit category_listings_path(cid: category, loc: site.id) 
      end
      
      it { should have_content('Pixis') }
      it { should have_content 'Guitar' }
      it { should have_content category.name_title }
    end  

    describe "GET /listings" do  
      let(:temp_listing) { FactoryGirl.create(:temp_listing, title: "Guitar", description: "Lessons", seller_id: @user.id ) }
      let(:listings) { 30.times { FactoryGirl.create(:listing, seller_id: @user.id) } }

      before(:each) do
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
      
      it { should have_link 'Recent' }
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
      end

      it "selects a site", js: true do
        fill_in "location", :with => 'pixi'
	set_site_id
        page.should have_content 'HP Printer J4580'

	click_link 'Recent'
        page.should have_content @listing.nice_title
      end

      it "selects categories", js: true do
        select(@category.name_title, :from => 'category_id')
        page.should have_content @category.name_title
        page.should_not have_content @listing1.nice_title
        page.should have_content @listing.nice_title
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
