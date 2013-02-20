require 'spec_helper'

describe "Listings", :type => :feature do
  subject { page }
  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    login_as(user, :scope => :user, :run_callbacks => false)
    user.confirm!
  end

  describe "Manage pixis" do
    let(:submit) { "Create Pixi" }
    let(:listing) { FactoryGirl.build :listing }

    before do 
      FactoryGirl.create :site
      FactoryGirl.create :category
      visit new_listing_path(user_id: user.id) 
    end

    describe "Create with invalid information" do
      it "should not create a listing" do
        expect { click_button submit }.not_to change(Listing, :count)
      end
    end

    describe "Create with valid information" do
      it "Adds a new listing and displays the results" do
        expect{
	        fill_in 'Title', with: "Guitar for Sale"
	        fill_in 'Description', with: "Guitar for Sale"
		select("SFSU", :from => "Site")
		select('Foo bar', :from => 'Category')
		attach_file('photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
	        click_button submit
	      }.to change(Listing,:count).by(1)
      
        within 'h4' do
          page.should have_content "Guitar for Sale" 
        end

        page.should have_content "Description: Guitar for Sale" 
      end	      
    end	      
  end

  describe "Edit Pixi" do 
    it "Changes a pixi" do
      listing = FactoryGirl.create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id )
      expect{
      	      visit edit_listing_path(listing)
	      fill_in 'Title', with: "Guitar for Sale"
	      fill_in 'Description', with: "Acoustic bass"
              click_button 'Save Pixi'
      }.to change(Listing,:count).by(0)

        within 'h4' do
          page.should have_content "Guitar for Sale" 
        end

      page.should have_content "Description: Acoustic bass" 
    end
  end

  describe "Remove Pixi" do 
    it "Deletes a pixi" do
      listing = FactoryGirl.create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id )
      visit listing_path(listing)
      expect{
              click_on 'Delete'
      }.to change(Listing,:count).by(-1)

      page.should have_content "Listings" 
      page.should_not have_content "Guitar Lessons" 
    end
  end

  describe "listing page" do
    let(:listing) { FactoryGirl.create(:listing) }
    before { visit listing_path(listing) }

    it { should have_selector('h4',    text: listing.title) }
    it { should have_selector('title', text: listing.title) }
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
