require 'spec_helper'

describe "PendingListings", :type => :feature do
  subject { page }
  let(:user) { FactoryGirl.create(:pixi_user) }

  before(:each) do
    login_as(user, :scope => :user, :run_callbacks => false)
    @user = user
    @listing = FactoryGirl.create :temp_listing_with_transaction
  end

  describe "Review Pending Orders" do 
    before { visit pending_listing_path(@listing) }

    it "Views an order" do
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
    let(:listings) { 30.times { FactoryGirl.create(:temp_listing_with_transaction, seller_id: @user.id) } }
    before :each do
      visit pending_listings_path 
    end

    it "should display listings" do 
      page.should have_content("Pending Orders")
    end

    it "paginate should list each listing" do
      @user.temp_listings.get_by_status('pending').paginate(page: 1).each do |listing|
        page.should have_selector('td', text: listing.title)
      end
    end
  end
end

