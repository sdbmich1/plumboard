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
    before { visit pending_listing_path(listing) }

    it { should have_selector('title', text: 'Review Pending Order') }
    it { should have_content 'Acoustic Guitar' }
    it { should have_content "Posted By: #{listing.seller_name}" }
    it { should_not have_link 'Follow', href: '#' }
    it { should_not have_selector('#contact_content') }
    it { should_not have_selector('#comment_content') }
    it { should have_link 'Back', href: pending_listings_path(status: 'pending') }
    it { should have_button('Deny') }
    it { should have_link 'Improper Content', href: deny_pending_listing_path(listing, reason: 'Improper Content') }
    it { should have_link 'Bad Pictures', href: deny_pending_listing_path(listing, reason: 'Bad Pictures') }
    it { should have_link 'Approve', href: approve_pending_listing_path(listing) }
    it { should have_content "ID: #{listing.pixi_id}" }
    it { should have_content "Posted: #{get_local_time(listing.start_date)}" }
    it { should have_content "Updated: #{get_local_time(listing.updated_at)}" }

    it "Returns to pending order list" do
      click_link 'Back'
      page.should have_content("Pending Orders")
    end

    it 'Approves an order' do
      expect {
        click_link 'Approve'; sleep 4
	}.to change(Listing, :count).by(1)

      page.should_not have_content listing.title 
      page.should have_content("Pending Orders")
    end

    it 'Denies an order for improper content' do
      expect {
        click_link 'Improper Content'; sleep 2
	}.to change(Listing, :count).by(0)

      page.should_not have_content listing.title 
      page.should have_content("Pending Orders")
    end

    it 'Denies an order for bad pictures' do
      expect {
        click_link 'Bad Pictures'; sleep 2
	}.to change(Listing, :count).by(0)

      page.should_not have_content listing.title 
      page.should have_content("Pending Orders")
    end
  end

  describe "GET /pending_listings" do  
    let(:listings) { 30.times { FactoryGirl.create(:temp_listing_with_transaction, seller_id: @user.id) } }
    before do
      @px_user = create :editor, email: 'jsnow@pxb.com'
      init_setup @px_user
      @pending_listing = FactoryGirl.create(:temp_listing, seller_id: @user.id, status: 'pending', title: 'Snare Drum') 
      @denied_listing = FactoryGirl.create(:temp_listing, seller_id: @user.id, status: 'denied', title: 'Xbox 360') 
      visit pending_listings_path(status: 'pending') 
    end

    it { should have_content('Pending Orders') }
    it { should_not have_content('No pixis found') }
    it { should have_selector('#denied-pixis') }
    it { should have_selector('#pending-pixis') }
    it { should have_link 'Active' }
    it { should have_link 'Denied' }
    it { should_not have_content(@denied_listing.title) }
    it { should have_content(@pending_listing.title) }

    it "displays denied listings", js: true do
      click_link 'Denied'
      page.should_not have_content('No pixis found')
      page.should have_content @denied_listing.title
      page.should_not have_content @pending_listing.title
    end

    it "paginate should list each listing" do
      @user.temp_listings.get_by_status('pending').paginate(page: 1).each do |listing|
        page.should have_selector('td', text: listing.title)
      end
    end
  end
end

