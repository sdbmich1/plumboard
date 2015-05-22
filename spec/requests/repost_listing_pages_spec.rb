require 'spec_helper'

feature "Repost Listings" do
    subject { page }
  
    let(:user) { create(:contact_user) }
    let(:pixter) { create :pixter, user_type_code: 'PT', confirmed_at: Time.now }
    let(:admin) { create :admin, confirmed_at: Time.now }
    let(:category) { create :category }
    let(:site) { create :site, name: 'Detroit', org_type: 'city' }
    let(:contact) { site.contacts.create attributes_for :contact, address: 'Metro', city: 'Detroit', state: 'MI', zip: '48227'}
    let(:condition_type) { create :condition_type, code: 'UG', description: 'Used - Good', hide: 'no', status: 'active' }

    before(:each) do
      add_region
      init_setup user
    end

    def check_page item
      page.should have_link 'Repost!', href: repost_listing_path(item)
      page.should_not have_link 'Edit', href: edit_temp_listing_path(item)
      page.should_not have_button 'Remove'
    end

    describe "Repost button" do
      before do
        @active_listing = create(:listing, seller_id: @user.id, title: 'Bookshelf', site_id: site.id, condition_type_code: condition_type.code)
        @sold_listing = create(:listing, seller_id: @user.id, title: 'Leather Briefcase', site_id: site.id, condition_type_code: condition_type.code) 
	@sold_listing.update_attribute(:status, 'sold')
        @expired_listing = create(:listing, seller_id: @user.id, title: 'TV', site_id: site.id, condition_type_code: condition_type.code)
	@expired_listing.update_attribute(:status, 'expired')
        @removed_listing = create(:listing, seller_id: @user.id, title: 'Suede Jacket', site_id: site.id, condition_type_code: condition_type.code) 
	@removed_listing.update_attribute(:status, 'removed')
      end

      it "should appear for expired pixi" do
        visit listing_path(@expired_listing)
	check_page @expired_listing
      end

      it "should appear for sold pixi" do
        visit listing_path(@sold_listing)
	check_page @sold_listing
      end

      it "should appear for removed pixi" do
        visit listing_path(@removed_listing)
	check_page @removed_listing
      end

      it "should not appear for pixi with other status" do
        visit listing_path(@active_listing)
        page.should_not have_link 'Repost!', href: repost_listing_path(@active_listing)
      end

      it "reposts an expired pixi" do
        visit listing_path(@expired_listing)
	check_page @expired_listing
        click_link 'Repost!'
        page.should have_content 'Pixis'    # should go back to home page
        visit listing_path(@expired_listing)
        page.should_not have_link 'Repost!', href: repost_listing_path(@expired_listing)   # pixi shouldn't be expired anymore
      end

      it "reposts a sold pixi" do
        visit listing_path(@sold_listing)
	check_page @sold_listing
	expect{
          click_link 'Repost!'
          page.should have_content 'Pixis'    # should go back to home page
        }.to change(Listing.active,:count).by(1)
      end

      it "reposts a removed pixi" do
        visit listing_path(@removed_listing)
	check_page @removed_listing
	expect{
          click_link 'Repost!'
          page.should have_content 'Pixis'    # should go back to home page
        }.to change(Listing.active,:count).by(1)
      end
    end
end
