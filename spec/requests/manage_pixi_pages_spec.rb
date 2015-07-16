require 'spec_helper'

feature "ManagePixis" do
  subject { page }
  
  let(:user) { create(:contact_user) }
  let(:pixi_user) { create(:pixi_user) }
  let(:buyer) { create(:pixi_user) }
  let(:admin_user) { create(:admin, user_type_code: 'AD') }

  def add_listing val, flg=true
    if flg
      listing = create :listing, seller_id: @user.id, title: "#{val.titleize} Listing", category_id: @category.id, site_id: @site.id
    else
      listing = create :temp_listing, seller_id: @user.id, title: "#{val.titleize} Listing", category_id: @category.id, site_id: @site.id
    end

    unless val == 'invoiced' || val == 'wanted'
      listing.status = val
      listing.save!
      sleep 2
      if flg
        expect(Listing.where("status = ?", val).count).to eq 1
      else
        expect(TempListing.where("status = ?", val).count).to eq 1
      end
    end

    if val == 'pending' || val == 'denied'
      #visit pending_listings_path(status: val, loc: @site.id, cid: @category.id)
      visit pending_listing_path(listing)
      page.should have_button('Deny')
      ['Improper Content', 'Bad Pictures', 'Insufficient Information'].each do |item|
        page.should have_link item, href: deny_pending_listing_path(listing, reason: item)
      end
      page.should have_link 'Approve', href: approve_pending_listing_path(listing)
      visit pending_listings_path(status: val, loc: @site.id, cid: @category.id)
    elsif val == 'draft'
      visit unposted_temp_listings_path(status: 'new/edit', loc: @site.id, cid: @category.id)
    elsif val == 'invoiced'
      @invoice = @user.invoices.build attributes_for(:invoice, buyer_id: buyer.id, status: 'unpaid')
      @details = @invoice.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: listing.pixi_id 
      @invoice.save!
      visit invoiced_listings_path(status: 'invoiced', loc: @site.id, cid: @category.id)
    elsif val == 'wanted'
      buyer.pixi_wants.create FactoryGirl.attributes_for :pixi_want, pixi_id: listing.pixi_id
      visit wanted_listings_path(status: 'wanted', loc: @site.id, cid: @category.id)
    else
      if val == 'sold'
        @invoice = @user.invoices.build attributes_for(:invoice, buyer_id: buyer.id, status: 'paid')
        @details = @invoice.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: listing.pixi_id 
        @invoice.save!
      end
      visit listings_path(status: val, loc: @site.id, cid: @category.id)
    end
    process_element val, flg if flg
  end

  def process_element val, flg
    str_arr = %w(Sold Active Expired Purchased Removed Draft Denied Invoiced)
    str_arr.select! { |x| x != val.titleize }
    page.should have_content "#{val.titleize} Listing" 
    date_header = val == "draft" ? "Last Updated" : "#{val.titleize} Date"
    page.should have_content date_header
    name_header = %w(sold invoiced wanted).include?(val) ? 'Buyer Name' :  'Seller Name'
    page.should have_content name_header
    str_arr.each do |str|
      page.should_not have_content "#{str} Listing"
    end
    page.should_not have_content 'No pixis found.'
    page.should have_content 'Export as CSV file'

    ftype = flg ? 'csv' : 'js'
    if val == 'pending'
      visit pending_listings_path(status: val, loc: @site.id, cid: @category.id, format: ftype)
    elsif val == 'draft'
      visit unposted_temp_listings_path(status: 'new/edit', loc: @site.id, cid: @category.id, format: ftype)
    elsif val == 'invoiced'
      visit invoiced_listings_path(loc: @site.id, cid: @category.id, format: ftype)
    elsif val == 'wanted'
      visit wanted_listings_path(loc: @site.id, cid: @category.id, format: ftype)
    else
      visit listings_path(status: val, loc: @site.id, cid: @category.id, format: ftype)
    end
  end

  describe "Manage Pixis page" do
    before do
      @category = create :category, name: 'Music'
      @site = create :site, name: 'Berkeley'
      @site.contacts.create FactoryGirl.attributes_for(:contact)
      16.times do
        @listing = create :listing, seller_id: pixi_user.id, status: 'active', title: 'Guitar', description: 'Lessons', category_id: @category.id, 
          site_id: @site.id
      end

      init_setup admin_user
      visit listings_path(status: 'active')
    end

    it "should display all active listings when category or location are not specified", js: true do
      page.should have_content 'Manage Pixis'
      page.should have_content 'Guitar'
      page.should have_content 'Lessons'
      page.should have_content 'Berkeley'
    end

    it "has 'next' and 'previous' page links" do
      page.should have_link "Next"
      page.should have_link "Previous"
    end

    it "has export CSV button" do
      page.should have_link 'Export as CSV file' # , href: wanted_listings_path(loc: @site.id, cid: @category.id, format: 'csv')
    end
  end

  describe "Manage Pixis page statuses: " do
    before do
      @category = create :category, name: 'Music'
      @site = create :site, name: 'Berkeley'
      init_setup admin_user
    end

    it "views pending listings", js: true do
      add_listing 'pending', false
    end

    it "views active listings", js: true do
      add_listing 'active'
    end

    it "views draft listings", js: true do
      add_listing 'draft', false
    end

    it "views expired listings", js: true do
      add_listing 'expired'
    end

    it "views sold listings", js: true do
      add_listing 'sold'
    end

    it "views removed listings", js: true do
      add_listing 'removed'
    end

    it "views denied listings", js: true do
      add_listing 'denied', false
    end

    it "views invoiced listings", js: true do
      add_listing 'invoiced'
    end

    it "views wanted listings", js: true do
      add_listing 'wanted'
    end
  end
end
