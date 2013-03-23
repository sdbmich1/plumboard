require 'spec_helper'

describe "Listings", :type => :feature do
  subject { page }
  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    login_as(user, :scope => :user, :run_callbacks => false)
    user.confirm!
    @user = user
  end

  describe "Review Pixis" do 
    let(:temp_listing) { FactoryGirl.create(:temp_listing, title: "Guitar", description: "Lessons", seller_id: user.id ) }
    let(:listing) { FactoryGirl.create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id, pixi_id: temp_listing.pixi_id) }
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
      page.should have_selector('span',    text: listing.title) 
      page.should have_selector('title', text: listing.title) 
    end
  end

  describe "GET /listings" do  
    it "should display listings" do 
      listing = FactoryGirl.create(:listing, title: 'paint fence') 
      visit listings_path  
      page.should have_content("paint fence")
    end
  end  

  describe "seller listings page" do
    it "should display seller listings" do 
      listing = FactoryGirl.create(:listing, title: 'paint fence', seller_id: user.id) 
      visit seller_listings_path
      page.should have_content("paint fence")
    end
  end

end
