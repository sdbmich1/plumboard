require 'spec_helper'

describe "Listings", :type => :feature do
  subject { page }
  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    login_as(user, :scope => :user, :run_callbacks => false)
    user.confirm!
  end

  describe "Edit Pixi" do 
    let(:submit) { "Preview" }
    before do 
      listing = FactoryGirl.create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id )
      visit edit_listing_path(listing)
    end

    it "should not change a listing" do
      expect { 
	      fill_in 'Title', with: nil
	      click_button submit 
	}.not_to change(Listing, :count)
    end

    it "Changes a pixi" do
      expect{
	      fill_in 'Title', with: "Guitar for Sale"
	      fill_in 'Description', with: "Acoustic bass"
              click_button submit
      }.to change(Listing,:count).by(0)

        within 'h4' do
          page.should have_content "Guitar for Sale" 
        end

      page.should have_content "Description: Acoustic bass" 
    end
  end

  describe "Review Pixis" do 
    let(:listing) { FactoryGirl.create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id ) }
    before { visit listing_path(listing) }

    it "Deletes a pixi" do
      expect{
              click_on 'Remove'
      }.to change(Listing,:count).by(-1)

      page.should have_content "Pixis" 
      page.should_not have_content "Guitar Lessons" 
    end

    it "Views a pixi" do
      page.should have_selector('h4',    text: listing.title) 
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
      visit seller_listings_path(user_id: user.id) 
      page.should have_content("paint fence")
    end
  end

end
