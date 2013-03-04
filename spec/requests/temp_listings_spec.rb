require 'spec_helper'

feature "TempListings" do
  subject { page }
  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    login_as(user, :scope => :user, :run_callbacks => false)
    user.confirm!
  end

  describe "Manage Temp Pixis" do
    let(:submit) { "Preview" }
    let(:temp_listing) { TempListing.new title: 'listing', description: 'test', site_id: 1, seller_id: user.id, category_id: 1, start_date: Time.now }

    before(:each) do
      @user = user
      FactoryGirl.create :site
      FactoryGirl.create :category
      visit new_temp_listing_path
    end

    def add_data
      fill_in 'Title', with: "Guitar for Sale"
      fill_in 'Description', with: "Guitar for Sale"
      select("SFSU", :from => "Site")
      select('Foo bar', :from => 'Category')
      attach_file('photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
    end

    describe "Create with invalid information" do
      it "should not create a listing" do
        expect { click_button submit }.not_to change(TempListing, :count)
      end
    end

    describe "Create with valid information" do
      it "Adds a new listing and displays the results" do
        expect{
		add_data
	        click_button submit
	      }.to change(TempListing,:count).by(1)
      
        within 'h4' do
          page.should have_content "Guitar for Sale" 
        end

        page.should have_content "Description: Guitar for Sale" 
      end	      
    end	      
  end

  describe "Edit Temp Pixi" do 
    let(:submit) { "Preview" }
    let(:temp_listing) { TempListing.new title: 'listing', description: 'test', site_id: 1, seller_id: 1, category_id: 1, start_date: Time.now }

    before(:each) do
      picture = temp_listing.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo.jpg")
      temp_listing.save!
      visit edit_temp_listing_path(temp_listing)
    end

    it "should not change a listing" do
      expect { 
	      fill_in 'Title', with: nil
	      click_button submit 
	}.not_to change(TempListing, :count)
    end

    it "Changes a pixi" do
      expect{
	      fill_in 'Title', with: "Guitar for Sale"
	      fill_in 'Description', with: "Acoustic bass"
       	      attach_file('photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
              click_button submit
      }.to change(TempListing,:count).by(0)

      within 'h4' do
        page.should have_content "Guitar for Sale" 
      end

      page.should have_content 'Successfully updated pixi.'
      page.should have_content "Description: Acoustic bass" 
    end
  end

  describe 'Removes a Pixi' do
    let(:temp_listing) { TempListing.new title: 'listing', description: 'test', site_id: 1, seller_id: user.id, category_id: 1, start_date: Time.now }

    before(:each) do
      @user = user
      picture = temp_listing.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo.jpg")
      temp_listing.save!
      visit temp_listing_path(temp_listing)
    end

    it "Deletes a pixi" do
      expect{
              click_link 'Remove'
      }.to change(TempListing,:count).by(-1)

      page.should have_content "Pixis" 
      page.should_not have_content "Guitar for Sale" 
    end
  end
end
