require 'spec_helper'

describe "Listings", :type => :feature do
  subject { page }

  describe "Manage listings" do
    let(:user) { FactoryGirl.create(:user) }
    let(:submit) { "Create Pixi" }
    before do 
      FactoryGirl.create :site
      FactoryGirl.create :category
      visit new_listing_path(user_id: user.id) 
    end

    describe "with invalid information" do
      it "should not create a listing" do
        expect { click_button submit }.not_to change(Listing, :count)
      end
    end

    describe "Add Pixi" do 
      it "Adds a new listing and displays the results" do
        expect{
		select("SFSU", :from => "Site")
	        fill_in 'Title', with: "Guitar for Sale"
	        fill_in 'Description', with: "Guitar for Sale"
		select('Foo bar', :from => 'Category')
	        fill_in 'Start', with: Date.today
		attach_file('photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
	        click_button submit
	      }.to change(Listing,:count).by(1)
      
        within 'h1' do
          page.should have_content "Guitar for Sale" 
        end

        page.should have_content "Posted: #{Date.today}" 
        page.should have_content "Description: Guitar for Sale" 
      end	      
    end

    it "Deletes a contact" do
      listing = FactoryGirl.create(:listing, title: "Guitar", description: "Lessons")
      expect{
      	      visit listings_path
              within "#listing_#{listing.id}" do
                click_link 'Destroy'
	      end
      }.to change(Listing,:count).by(-1)

      it { should have_content "Show listings" }
      it { should_not have_content "Guitar Lessons" }
    end
  end

  describe "listing page" do
    let(:listing) { FactoryGirl.create(:listing) }
    before { visit listing_path(listing) }

    it { should have_selector('h1',    text: listing.title) }
    it { should have_selector('title', text: listing.title) }
  end
end
