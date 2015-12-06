require 'spec_helper'

 def check_page item, flg
   sleep 1
   page.should have_link 'Repost!' #, href: repost_listing_path(item, adminFlg: flg)
   page.should_not have_link 'Edit', href: edit_temp_listing_path(item)
   page.should_not have_button 'Remove'
 end

 def process_repost str
   expect{
     click_link 'Repost!'
     page.should have_content str
   }.to change(Listing.active,:count).by(1)
 end

shared_examples 'repost_pixi_pages' do |val, flg|
  describe 'view pixis' do
    before do
      @active_listing = create(:listing, seller_id: @user.id, title: 'Bookshelf', site_id: site.id, condition_type_code: condition_type.code)
      @listing = create(:listing, seller_id: @user.id, title: 'Leather Briefcase', site_id: site.id, condition_type_code: condition_type.code) 
      @listing.update_attribute(:status, val)
      @listing.update_attribute(:end_date, '01/01/2015'.to_date) if val == 'expired'
    end

    it "should appear for " + val + " pixi" do
      visit listing_path(@listing)
      check_page @listing, flg
    end

    it "should not appear for pixi with other status" do
      visit listing_path(@active_listing)
      page.should_not have_link 'Repost!' #, href: repost_listing_path(@active_listing)
    end

    it "reposted a " + val + " pixi" do
      visit listing_path(@listing)
      check_page @listing, flg
      click_link 'Repost!'
      str = flg ? 'Manage Pixis' : 'My Pixis'
      page.should have_content str
    end

    it "redirects a reposted pixi" do
      visit listing_path(@listing)
      check_page @listing, flg
      str = flg ? 'Manage Pixis' : 'My Pixis'
      process_repost str
    end
  end
end
