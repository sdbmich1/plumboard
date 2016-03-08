require 'spec_helper'

feature 'Favorite Sellers' do
  subject { page }

  let(:user) { create :contact_user }
  let(:seller) { create :contact_user, user_type_code: 'BUS', business_name: 'Rhythm Music' }

  describe 'My Sellers' do
    def test_navbar(page_name, status)
      ftype = page_name == 'My Followers' ? 'seller' : 'buyer'
      expect(page).to have_content page_name
      expect(page).to have_link 'Followed', href: favorite_sellers_path(ftype: ftype,
        id: user.id, status: 'active'), class: (status == 'active' ? 'active' : '')
      expect(page).to have_link 'Unfollowed', href: favorite_sellers_path(ftype: ftype,
        id: user.id, status: 'removed'), class: (status == 'removed' ? 'active' : '')
    end

    def test_table(active=true, has_addr=false)
      addr = has_addr ? seller.primary_address : seller.home_zip
      expect(page).to have_content 'Seller Name'
      expect(page).to have_content 'Location'
      expect(page).to have_content '# Pixis'
      expect(page).to have_content 'Follow Date'
      expect(page).to have_css 'img'
      expect(page).to have_content seller.business_name
      expect(page).to have_content addr
      expect(page).to have_content seller.listings.count
      expect(page).to have_content Date.today.strftime('%m/%d/%Y')
      expect(page).to have_content 'View'
    end

    before :each do
      init_setup user
    end

    it 'renders Followed' do
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'active'
      visit favorite_sellers_path(ftype: 'buyer', id: user.id, status: 'active')
      test_navbar('My Sellers', 'active')
      test_table
      expect(page).to have_content 'Displaying ' << FavoriteSeller.count.to_s << ' sellers'
    end

    it 'renders Unfollowed' do
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'removed'
      visit favorite_sellers_path(ftype: 'buyer', id: user.id, status: 'removed')
      test_navbar('My Sellers', 'removed')
      test_table(false)
      expect(page).to have_content 'Displaying ' << FavoriteSeller.count.to_s << ' sellers'
    end

    it 'renders "No sellers found" if no sellers' do
      visit favorite_sellers_path(ftype: 'buyer', id: user.id, status: 'active')
      test_navbar('My Sellers', 'active')
      expect(page).to have_content 'No followed sellers found.'
    end

    it 'splits more than 15 entries into separate pages' do
      for char in "a".."z"
        business = create :contact_user, user_type_code: 'BUS', business_name: 'business ' + char
        create :favorite_seller, user_id: user.id, seller_id: business.id, status: 'active'
      end
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'active'
      visit favorite_sellers_path(ftype: 'buyer', id: user.id, status: 'active')
      expect(page).to have_content 'Displaying sellers'
      expect(page).to have_selector('div.pagination')
      click_link '2'
      test_navbar('My Sellers', 'active')
      test_table
    end

    it 'displays seller address if available' do
      seller.contacts.create
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'active'
      visit favorite_sellers_path(ftype: 'buyer', id: user.id, status: 'active')
      test_navbar('My Sellers', 'active')
      test_table(true, true)
    end
  end
end