require 'spec_helper'

describe "Listings", :type => :feature do
  subject { page }
  
  let(:user) { FactoryGirl.create(:contact_user) }
  let(:temp_listing) { FactoryGirl.create(:temp_listing, title: "Guitar", description: "Lessons", seller_id: user.id ) }
  let(:listing) { FactoryGirl.create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id, pixi_id: temp_listing.pixi_id) }

  describe "Contact Owner" do 
    let(:pixi_user) { FactoryGirl.create(:pixi_user) }

    before(:each) do
      login_as(pixi_user, :scope => :user, :run_callbacks => false)
      pixi_user.confirm!
      @user = pixi_user
      visit listing_path(listing) 
    end
     
    it "Contacts a seller", js: true do
      expect{
      	  fill_in 'post_content', with: "I'm interested in this pixi. Please contact me." 
          click_on 'Contact Owner'; sleep 3
      }.to change(Post,:count).by(1)

      page.should have_content listing.title
    end
     
    it "should not contact a seller", js: true do
      expect{
	      fill_in 'post_content', with: nil
              click_on 'Contact Owner'; sleep 3
      }.not_to change(Post,:count).by(1)

      page.should have_content "Content can't be blank"
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

    it "Edits a pixi" do
      click_link 'Edit'
      page.should have_content("Build Pixi")
    end

    it "Returns to pixi list" do
      click_link '<< Back'
      page.should have_content("Pixis")
    end

    it "Views a pixi" do
      page.should have_selector('title', text: listing.nice_title) 
    end
  end

  describe "GET /listings" do  
    let(:listings) { 30.times { FactoryGirl.create(:listing, seller_id: @user.id) } }
    before { visit listings_path }
      
    it "should display listings" do 
      page.should have_content('Pixis')
    end
      
    it "should scroll listings", js: true do 
      page.execute_script "window.scrollBy(0,1000)"
    end
  end  

  describe "seller listings page" do
    let(:listings) { 30.times { FactoryGirl.create(:listing, seller_id: @user.id) } }
    before { visit seller_listings_path }
      
    it "should display seller listings" do 
      page.should have_content('My Pixis')
    end

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
