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
    let(:temp_listing) { FactoryGirl.build(:temp_listing) }

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
    let(:temp_listing) { FactoryGirl.create(:temp_listing) }
    before { visit edit_temp_listing_path(temp_listing) }

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

  describe 'Reviews a Pixi' do
    let(:temp_listing) { FactoryGirl.create(:temp_listing, seller_id: user.id) }
    before { visit temp_listing_path(temp_listing) }

    it "Deletes a pixi" do
      expect{
              click_link 'Remove'
      }.to change(TempListing,:count).by(-1)

      page.should have_content "Pixis" 
      page.should_not have_content "Guitar for Sale" 
    end

    it "Views a pixi" do
      page.should have_selector('h4',    text: temp_listing.title) 
      page.should have_selector('title', text: temp_listing.title) 
    end

    it "Submits a pixi" do
      expect { 
	      click_on 'Submit' 
	}.not_to change(TempListing, :count)

      page.should_not have_content "Pixis" 
      page.should have_content "Order Summary" 
    end
  end

end
