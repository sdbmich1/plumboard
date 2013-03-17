require 'spec_helper'

feature "TempListings" do
  subject { page }
  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    login_as(user, :scope => :user, :run_callbacks => false)
    user.confirm!
  end

  describe "Manage Temp Pixis" do
    let(:submit) { "Next Step: Review >>" }
    let(:temp_listing) { FactoryGirl.build(:temp_listing) }

    before(:each) do
      @user = user
      FactoryGirl.create :site
      FactoryGirl.create :category
      visit new_temp_listing_path
    end

    def add_data
      fill_in 'Title', with: "Guitar for Sale"
      select("SFSU", :from => "Site")
      select('Foo bar', :from => 'Category')
      fill_in 'Description', with: "Guitar for Sale"
    end

    def add_data_w_photo
      attach_file('photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
      add_data
    end

    describe "Create with invalid information" do
      it "should not create a listing" do
        expect { click_button submit }.not_to change(TempListing, :count)
      end

      it "should not create a listing w/o site" do
        expect { 
          fill_in 'Title', with: "Guitar for Sale"
          fill_in 'Price', with: "150.00"
          select('Foo bar', :from => 'Category')
          fill_in 'Description', with: "Guitar for Sale"
          attach_file('photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
	  click_button submit }.not_to change(TempListing, :count)
      end

      it "should not create a listing w/o category" do
        expect { 
          fill_in 'Title', with: "Guitar for Sale"
          fill_in 'Price', with: "150.00"
          select("SFSU", :from => "Site")
          fill_in 'Description', with: "Guitar for Sale"
          attach_file('photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
	  click_button submit }.not_to change(TempListing, :count)
      end

      it "should not create a listing w/o photo" do
        expect { 
	  add_data
	  click_button submit }.not_to change(TempListing, :count)
      end
    end

    describe "Create with valid information" do
      it "Adds a new listing w/o price and displays the results" do
        expect{
		add_data_w_photo
	        click_button submit
	      }.to change(TempListing,:count).by(1)
      
        within 'span' do
          page.should have_content "Guitar For Sale" 
        end
        page.should have_content 'Review Your Pixi'
      end	      

      it "Adds a new listing w price and displays the results" do
        expect{
		add_data_w_photo
                fill_in 'Price', with: "150.00"
	        click_button submit
	      }.to change(TempListing,:count).by(1)
      
        page.should have_content "Description: Guitar for Sale" 
        page.should have_content 'Review Your Pixi'
      end	      
    end	      
  end

  describe "Edit Invalid Temp Pixi" do 
    let(:submit) { "Next Step: Review >>" }
    let(:temp_listing) { FactoryGirl.create(:temp_listing) }
    before { visit edit_temp_listing_path(temp_listing) }

    it "empty title should not change a listing" do
      expect { 
	      fill_in 'Title', with: nil
	      click_button submit 
	}.not_to change(TempListing, :count)

      page.should have_content 'Build Pixi'
    end

    it "empty description should not change a listing" do
      expect { 
	      fill_in 'Description', with: nil
	      click_button submit 
	}.not_to change(TempListing, :count)

      page.should have_content 'Build Pixi'
    end

    it "invalid price should not change a listing" do
      expect { 
	      fill_in 'Price', with: '$500'
	      click_button submit 
	}.not_to change(TempListing, :count)

      page.should have_content 'Build Pixi'
    end

    it "huge price should not change a listing" do
      expect { 
	      fill_in 'Price', with: '5000000'
	      click_button submit 
	}.not_to change(TempListing, :count)

      page.should have_content 'Build Pixi'
    end

    it "Empty picture should not change a listing" do
      expect { 
	      check('delete_photo')
	      click_button submit 
      }.to change(temp_listing.pictures,:count).by(-1)

      page.should have_content 'Build Pixi'
    end
  end

  describe "Edit Temp Pixi" do 
    let(:submit) { "Next Step: Review >>" }
    let(:temp_listing) { FactoryGirl.create(:temp_listing) }
    before { visit edit_temp_listing_path(temp_listing) }

    it "Changes a pixi title" do
      expect{
	      fill_in 'Title', with: "Guitar for Sale"
              click_button submit
      }.to change(TempListing,:count).by(0)

      page.should have_content "Guitar For Sale" 
      page.should have_content 'Review Your Pixi'
    end

    it "Changes a pixi description" do
      expect{
	      fill_in 'Description', with: "Acoustic bass"
              click_button submit
      }.to change(TempListing,:count).by(0)

      page.should have_content 'Review Your Pixi'
      page.should have_content "Description: Acoustic bass" 
    end

    it "Adds a pixi pic" do
      expect{
              attach_file('photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
              click_button submit
      }.to change(temp_listing.pictures,:count).by(1)

      page.should have_content 'Review Your Pixi'
    end

    it "Changes a pixi price" do
      expect{
              fill_in 'Price', with: nil
              click_button submit
      }.to change(TempListing,:count).by(0)

      page.should have_content 'Review Your Pixi'
    end
  end

  describe 'Reviews a Pixi' do
    let(:temp_listing) { FactoryGirl.create(:temp_listing, seller_id: user.id) }
    before { visit temp_listing_path(temp_listing) }

    it "Views a pixi" do
      page.should have_content "Acoustic Guitar" 
    end

    it "Deletes a pixi" do
      expect{
              click_link 'Cancel'
      }.to change(TempListing,:count).by(-1)

      page.should have_content "Pixis" 
      page.should_not have_content "Guitar For Sale" 
    end

    it "Submits a pixi" do
      expect { 
	      click_button 'Next Step: Submit >>'
	}.not_to change(TempListing, :count)

      page.should have_content "Submit Your Order" 
    end

    it "Builds a pixi" do
      expect { 
	      click_link '<< Prev Step: Build'
	}.not_to change(TempListing, :count)

      page.should have_content "Build Pixi" 
    end
  end

end
