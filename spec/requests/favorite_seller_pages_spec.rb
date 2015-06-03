require 'spec_helper'

feature 'Favorite Sellers' do
  subject { page }

  let(:user) { create :contact_user }
  let(:seller) { create :contact_user, user_type_code: 'BUS', business_name: 'Rhythm Music' }

  describe 'My Sellers' do
    def test_navbar(page_name, status)
      ftype = page_name == 'My Followers' ? 'seller' : 'buyer'
      page.should have_content page_name
      page.should have_link 'Active', href: favorite_sellers_path(ftype: ftype,
        id: user.id, status: 'active'), class: (status == 'active' ? 'active' : '')
      page.should have_link 'Inactive', href: favorite_sellers_path(ftype: ftype,
        id: user.id, status: 'removed'), class: (status == 'removed' ? 'active' : '')
    end

    def test_table(active=true, has_addr=false)
      addr = has_addr ? seller.primary_address : seller.home_zip
      page.should have_content 'Seller Name'
      page.should have_content 'Location'
      page.should have_content '# Active Pixis'
      page.should have_content 'Follow Date'
      page.should have_css 'img'
      page.should have_content seller.business_name
      page.should have_content addr
      page.should have_content seller.listings.count
      page.should have_content Date.today.strftime('%m/%d/%Y')
      page.should have_content 'View'
      if active
        page.should have_link('Unfollow',
          href: favorite_seller_path(id: user.favorite_seller_id(seller.id),
            seller_id: seller.id), id: 'unfollow-btn')
      else
        page.should have_link('Follow',
          href: favorite_sellers_path(seller_id: seller.id), id: 'follow-btn')
      end
    end

    before :each do
      init_setup user
    end

    it 'renders Active' do
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'active'
      visit favorite_sellers_path(ftype: 'buyer', id: user.id, status: 'active')
      test_navbar('My Sellers', 'active')
      test_table
      page.should have_content 'Displaying ' << FavoriteSeller.count.to_s << ' sellers'
    end

    it 'renders Inactive' do
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'removed'
      visit favorite_sellers_path(ftype: 'buyer', id: user.id, status: 'removed')
      test_navbar('My Sellers', 'removed')
      test_table(false)
      page.should have_content 'Displaying ' << FavoriteSeller.count.to_s << ' sellers'
    end

    it 'renders "No sellers found" if no sellers' do
      visit favorite_sellers_path(ftype: 'buyer', id: user.id, status: 'active')
      test_navbar('My Sellers', 'active')
      page.should have_content 'No followed sellers found.'
    end

    it 'splits more than 15 entries into separate pages' do
      for char in "a".."z"
        business = create :contact_user, user_type_code: 'BUS', business_name: 'business ' + char
        create :favorite_seller, user_id: user.id, seller_id: business.id, status: 'active'
      end
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'active'
      visit favorite_sellers_path(ftype: 'buyer', id: user.id, status: 'active')
      page.should have_content 'Displaying sellers'
      page.should have_selector('div.pagination')
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