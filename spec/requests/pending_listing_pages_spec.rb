require 'spec_helper'

describe "PendingListings", :type => :feature do
  subject { page }
  let(:user) { FactoryGirl.create :pixi_user }
  let(:listing) { FactoryGirl.create :temp_listing_with_transaction, seller_id: user.id }

  def init_setup usr
    login_as(usr, :scope => :user, :run_callbacks => false)
    @user = usr
  end

  before(:each) do
    user = FactoryGirl.create :editor, email: 'jsnow@pixitext.com', confirmed_at: Time.now 
    init_setup user
  end

  describe "Review Pending Orders" do 
    before { visit pending_listing_path(listing, status: 'pending') }

    it 'shows content' do
      page.should have_selector('title', text: 'Review Pending Order')
      page.should have_content 'Acoustic Guitar'
      page.should have_content "Posted By: #{listing.seller_name}"
      page.should_not have_link 'Follow', href: '#'
      page.should_not have_selector('#contact_content')
      page.should_not have_selector('#comment_content')
      page.should_not have_content('Want')
      page.should_not have_content('Cool')
      page.should_not have_content('Saved')
      page.should have_link 'Active'
      page.should have_link 'Denied'
      page.should have_link 'Edit', href: edit_temp_listing_path(listing)
      page.should have_link 'Back', href: pending_listings_path(status: 'pending')
      page.should have_button('Deny')
      page.should have_link 'Improper Content', href: deny_pending_listing_path(listing, reason: 'Improper Content')
      page.should have_link 'Bad Pictures', href: deny_pending_listing_path(listing, reason: 'Bad Pictures')
      page.should have_link 'Approve', href: approve_pending_listing_path(listing)
      page.should have_content "ID: #{listing.pixi_id}"
      page.should have_content "Posted:" # #{get_local_time(listing.start_date)}"
      page.should have_content "Updated:" # #{get_local_time(listing.updated_at)}"
    end

    it "Returns to pending order list" do
      click_link 'Back'
      page.should have_content("Pending Orders")
    end

    it 'edits content' do
      click_link 'Edit'
      page.should have_selector('.sm-thumb')
      page.should have_selector('#photo')
      page.should have_content 'Build Pixi'
      page.should have_button 'Next'
    end

    it 'Approves an order' do
      expect {
        click_link 'Approve'
        page.should_not have_content listing.title 
        page.should have_content("Pending Orders")
	}.to change(Listing, :count).by(1)
    end

    it 'Denies an order for improper content' do
      expect {
        click_link 'Improper Content'; sleep 2
        page.should_not have_content listing.title 
        page.should have_content("Pending Orders")
	listing.reload.status.should == 'denied'
      }.to change(Listing, :count).by(0)
    end

    it 'Denies an order for bad pictures' do
      expect {
        click_link 'Bad Pictures'; sleep 2
        page.should_not have_content listing.title 
        page.should have_content("Pending Orders")
	}.to change(Listing, :count).by(0)
    end

    it "displays denied listings" do
      click_link 'Denied'
      page.should have_content('No pixis found')
    end

    it "displays active listings" do
      click_link 'Active'
      page.should have_link 'Active'
      page.should have_content 'Location'
      page.should have_content 'Last Updated'
    end
  end

  describe "GET /pending_listings" do  
    let(:listings) { 30.times { FactoryGirl.create(:temp_listing_with_transaction, seller_id: @user.id) } }
    before do
      @px_user = create :editor, email: 'jsnow@pxb.com'
      init_setup @px_user
      @pending_listing = FactoryGirl.create(:temp_listing, seller_id: @user.id, status: 'pending', title: 'Snare Drum') 
    end

    it 'shows content' do
      visit pending_listings_path(status: 'pending')
      page.should have_content('Pending Orders')
      page.should_not have_content('No pixis found')
      page.should have_selector('#denied-pixis')
      page.should have_selector('#pending-pixis')
      page.should have_link 'Active'
      page.should have_link 'Denied'
      page.should have_content(@pending_listing.title)
    end
    
    it "paginate should list each listing" do
      visit pending_listings_path(status: 'pending')
      @user.temp_listings.get_by_status('pending').paginate(page: 1).each do |listing|
        page.should have_selector('td', text: listing.title)
      end
    end
  end
end

