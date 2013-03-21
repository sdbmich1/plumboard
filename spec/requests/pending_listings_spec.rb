require 'spec_helper'

describe "PendingListings", :type => :feature do
  subject { page }
  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    login_as(user, :scope => :user, :run_callbacks => false)
    user.confirm!
    @listing = FactoryGirl.create :temp_listing_with_transaction
    @listing.status = 'pending'
    @listing.save!
  end

  describe "Review Pending Orders" do 
    before { visit pending_listing_path(@listing) }

    it "Views an order" do
      page.should have_selector('span',  text: @listing.nice_title) 
      page.should have_selector('title', text: 'Review Pending Order') 
    end

    it "Returns to pending order list" do
      click_link '<< Back'

      page.should have_content("Pending Orders")
    end

    it 'Approves an order' do
      expect {
        click_link 'Approve'
	}.to change(Listing, :count).by(1)

      page.should have_content("Pending Orders")
    end

    it 'Denies an order' do
      expect {
        click_link 'Deny'
	}.to change(Listing, :count).by(0)

      page.should have_content("Pending Orders")
    end
  end

  describe "GET /pending_listings" do  
    it "should display listings" do 
      visit pending_listings_path  
      page.should have_content("Pending Orders")
    end
  end
end

