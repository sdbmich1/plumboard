require 'spec_helper'

feature "Listings" do
  subject { page }
  
  let(:user) { FactoryGirl.create(:contact_user) }
  let(:listings) { 30.times { create(:listing, seller_id: user.id) } }

  def add_listing val, flg=true, other_id=nil
    if flg
      if other_id
        listing = create :listing, seller_id: other_id, buyer_id: user.id, title: "#{val.titleize} Listing"
      else
        listing = create :listing, seller_id: user.id, title: "#{val.titleize} Listing"
      end
      if val == 'wanted'
        user.pixi_wants.create FactoryGirl.attributes_for :pixi_want, pixi_id: listing.pixi_id
      else
        user.pixi_wants.create FactoryGirl.attributes_for :pixi_like, pixi_id: listing.pixi_id
      end
      user.saved_listings.create FactoryGirl.attributes_for :saved_listing, pixi_id: listing.pixi_id
      add_invoice(val, other_id, listing)
    else
      listing = create :temp_listing, seller_id: user.id, title: "#{val.titleize} Listing"
    end

    unless val == 'invoiced' || val == 'wanted'
      val = val == 'draft' ? 'new' : val 
      listing.status = val 
      listing.save!
      sleep 2
      if flg
        expect(Listing.where("status = ?", val).count).to eq 1
      else
        expect(TempListing.where("status = ?", val).count).to eq 1
      end
    end
  end

  def add_invoice val, other_id, listing
    if val == 'sold'
      invoice = listing.invoices.build FactoryGirl.attributes_for :invoice, buyer_id: other_id, seller_id: user.id, status: 'paid'
      listing.buyer_id = other_id
    elsif val == 'purchased'
      invoice = listing.invoices.build FactoryGirl.attributes_for :invoice, buyer_id: user.id, seller_id: other_id, status: 'paid'
    end
    if val == 'sold' || val == 'purchased'
      invoice.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: listing.pixi_id
      invoice.save!
    end
  end

  def process_element val, saved=false
    str_arr = %w(Sold Active Expired Purchased Removed Draft Denied)
    str_arr.select! { |x| x != val.titleize }
    page.should have_content(saved ? "Active Listing" : "#{val.titleize} Listing")
    if val == "draft"
      date_column = "Last Updated"
    elsif saved
      date_column = "Saved Date"
    else
      date_column = "#{val.titleize} Date"
    end
    page.should have_content date_column
    check_page_expectations str_arr, 'Listing'
    page.should_not have_content 'No pixis found.'
  end

  describe "My Pixis pagination", js: true do
    it "should list each listing" do
      user.pixis.paginate(page: 1).each do |listing|
        page.should have_selector('td', text: listing.title)
      end
    end
  end

  describe "My pixis page" do
    before do
      @other_user = create :pixi_user, email: 'john.doe@pxb.com'
      init_setup user
      @temp_listing = create(:temp_listing, seller_id: user.id) 
    end
      
    it "views my pixis page", js: true do
      visit seller_listings_path(status: 'active', adminFlg: false)
      page.should have_content('My Pixis')
      page.should have_link 'Active', href: seller_listings_path(status: 'active', adminFlg: false)
      page.should have_link 'Draft', href: unposted_temp_listings_path(status: 'draft', adminFlg: false)
      page.should have_link 'Pending', href: pending_temp_listings_path(status: 'pending', adminFlg: false)
      page.should have_link 'Purchased', href: purchased_listings_path(status: 'purchased')
      page.should have_link 'Sold', href: seller_listings_path(status: 'sold', adminFlg: false)
      page.should have_link 'Saved', href: saved_listings_path(status: 'saved')
      page.should have_link 'Wanted', href: seller_wanted_listings_path(status: 'wanted')
      page.should have_link 'Expired', href: seller_listings_path(status: 'expired', adminFlg: false)
    end

    it "displays active listings", js: true do
      add_listing 'active'
      visit seller_listings_path(status: 'active', adminFlg: false)
      process_element 'active'
    end

    it "displays sold listings", js: true do
      add_listing 'sold', true, @other_user.id
      visit seller_listings_path(status: 'sold', adminFlg: false)
      process_element 'sold'
    end

    it "displays draft listings", js: true do
      add_listing 'draft', false
      visit unposted_temp_listings_path(status: 'draft', adminFlg: false)
      process_element 'draft'
    end

    it "displays pending listings", js: true do
      add_listing 'pending', false
      visit pending_temp_listings_path(status: 'pending', adminFlg: false)
      process_element 'pending'
    end

    it "displays saved listings", js: true do
      add_listing 'active'
      visit saved_listings_path(status: 'saved')
      process_element 'active', true
    end

    it "display wanted listings", js: true do
      add_listing 'wanted'
      visit seller_wanted_listings_path(status: 'wanted')
      process_element 'wanted'
    end

    it "display purchased listings", js: true do
      add_listing 'purchased', true, @other_user.id
      visit purchased_listings_path(status: 'purchased')
      process_element 'purchased'
    end

    it "display expired listings", js: true do
      add_listing 'expired'
      visit seller_listings_path(status: 'expired', adminFlg: false)
      process_element 'expired'
    end
  end
end
