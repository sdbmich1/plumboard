require 'spec_helper'

describe "PendingListings", :type => :feature do
  subject { page }
  let(:user) { FactoryGirl.create :pixi_user }
  let(:condition_type) { create :condition_type, code: 'UG', description: 'Used - Good', hide: 'no', status: 'active' }
  let(:listing) { FactoryGirl.create :temp_listing_with_transaction, seller_id: user.id, condition_type_code: condition_type.code }

  before(:each) do
    user = FactoryGirl.create :editor, email: 'jsnow@pixitext.com', confirmed_at: Time.now 
    init_setup user
  end

  describe "Review Pending Orders" do 
    before { visit pending_listing_path(listing) }

    it 'shows content' do
      expect(page).to have_selector('title', text: 'Review Pending Order')
      expect(page).to have_content 'Acoustic Guitar'
      expect(page).to have_content "Posted By: #{listing.seller_name}"
      expect(page).not_to have_link 'Follow', href: '#'
      expect(page).not_to have_selector('#contact_content')
      expect(page).not_to have_selector('#comment_content')
      expect(page).not_to have_content('Want')
      expect(page).not_to have_content('Cool')
      expect(page).not_to have_content('Saved')
      expect(page).to have_link 'Active'
      expect(page).to have_link 'Denied'
      expect(page).to have_link 'Edit'
      expect(page).to have_link 'Back', href: pending_listings_path(status: 'pending')
      expect(page).to have_button('Deny')
      expect(page).to have_link 'Improper Content', href: deny_pending_listing_path(listing, reason: 'Improper Content')
      expect(page).to have_link 'Bad Pictures', href: deny_pending_listing_path(listing, reason: 'Bad Pictures')
      expect(page).to have_link 'Approve', href: approve_pending_listing_path(listing)
      expect(page).to have_content "ID: #{listing.pixi_id}"
      expect(page).to have_content "Posted:" # #{get_local_time(listing.start_date)}"
      expect(page).to have_content "Updated:" # #{get_local_time(listing.updated_at)}"
    end

    it "Returns to pending order list" do
      click_link 'Back'
      expect(page).to have_content("Manage Pixis")
    end

    it 'edits content' do
      click_link 'Edit'
      expect(page).to have_selector('.sm-thumb')
      expect(page).to have_selector('#photo')
      expect(page).to have_content 'Build Your Pixi'
      expect(page).to have_button 'Next'
      expect{
	      fill_in 'Description', with: "Acoustic bass"
              click_button 'Next'
      }.to change(TempListing,:count).by(0)
      expect(page).to have_content 'Review Your Pixi'
      expect(page).not_to have_content @user.name
      expect(page).to have_content listing.seller_name
    end

    it "adds a pixi pic", js: true do
      click_link 'Edit'
      expect(page).to have_selector('.sm-thumb')
      expect(page).to have_selector('#photo')
      expect(page).to have_content 'Build Your Pixi'
      expect{
              attach_file('photo', Rails.root.join("spec", "fixtures", "photo0.jpg"))
              click_button 'Next'
      }.to change(listing.pictures,:count).by(1)
      expect(page).to have_content 'Review Your Pixi'
      expect(page).not_to have_content @user.name
      expect(page).to have_content listing.seller_name
    end

    it 'Approves an order' do
      expect {
        click_link 'Approve'
        expect(page).not_to have_content listing.title 
        expect(page).to have_content("Manage Pixis")
	}.to change(Listing, :count).by(1)
    end

    it 'Denies an order for improper content' do
      expect {
        click_link 'Improper Content'; sleep 2
        expect(page).not_to have_content listing.title 
        expect(page).to have_content("Manage Pixis")
	expect(listing.reload.status).to eq('denied')
      }.to change(Listing, :count).by(0)
    end

    it 'Denies an order for bad pictures' do
      expect {
        click_link 'Bad Pictures'; sleep 2
        expect(page).not_to have_content listing.title 
        expect(page).to have_content("Manage Pixis")
	}.to change(Listing, :count).by(0)
    end

    it "displays denied listings" do
      click_link 'Denied'
      expect(page).to have_content('No pixis found')
    end

    it "displays active listings" do
      click_link 'Active'
      expect(page).to have_content("Manage Pixis")
      expect(page).to have_content 'Location'
      expect(page).to have_content 'Last Updated'
      expect(page).to have_content listing.title
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
      expect(page).to have_content('Manage Pixis')
      expect(page).not_to have_content('No pixis found')
      # page.should have_selector('#denied-pixis')
      # page.should have_selector('#pending-pixis')
      expect(page).to have_content(@pending_listing.title)
    end
    
    it "paginate should list each listing" do
      visit pending_listings_path(status: 'pending')
      @user.temp_listings.get_by_status('pending').paginate(page: 1).each do |listing|
        expect(page).to have_selector('td', text: listing.title)
      end
    end
  end
end

