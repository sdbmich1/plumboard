require 'spec_helper'

feature 'Favorite Sellers' do
  subject { page }

  let(:user) { create :contact_user }
  let(:seller) { create :contact_user, user_type_code: 'BUS', business_name: 'Rhythm Music' }

  def test_navbar(page_name, status)
    ftype = page_name == 'My Followers' ? 'seller' : 'buyer'
    user_id = page_name == 'My Followers' ? seller.id : nil
    page.should have_content page_name
    page.should have_link 'Active', href: favorite_sellers_path(ftype: ftype,
      id: user_id, status: 'active'), class: (status == 'active' ? 'active' : '')
    page.should have_link 'Inactive', href: favorite_sellers_path(ftype: ftype,
      id: user_id, status: 'removed'), class: (status == 'removed' ? 'active' : '')
  end

  describe 'My Followers' do
    def test_table(usr, has_addr=false)
      addr = has_addr ? usr.primary_address : usr.home_zip
      page.should have_content 'User Name'
      page.should have_content 'Location'
      page.should have_content 'Follow Date'
      page.should have_css 'img'
      page.should have_content usr.name
      page.should have_content addr
      page.should have_content Date.today.strftime('%m/%d/%Y')
    end

    before :each do
      init_setup user
    end

    it 'renders Active' do
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'active'
      visit favorite_sellers_path(ftype: 'seller', id: seller.id, status: 'active')
      test_navbar('My Followers', 'active')
      test_table(user)
      page.should have_content 'Displaying ' << FavoriteSeller.count.to_s << ' followers'
    end

    it 'renders Inactive' do
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'removed'
      visit favorite_sellers_path(ftype: 'seller', id: seller.id, status: 'removed')
      test_navbar('My Followers', 'removed')
      test_table(user)
      page.should have_content 'Displaying ' << FavoriteSeller.count.to_s << ' followers'
    end

    it 'renders "No sellers found" if no sellers' do
      visit favorite_sellers_path(ftype: 'seller', id: seller.id, status: 'active')
      test_navbar('My Followers', 'active')
      page.should have_content 'No followers found.'
    end

    it 'splits more than 15 entries into separate pages' do
      15.times do
        @follower = create :contact_user
        create :favorite_seller, user_id: @follower.id, seller_id: seller.id, status: 'active'
      end
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'active'
      visit favorite_sellers_path(ftype: 'seller', id: seller.id, status: 'active')
      page.should have_content 'Displaying followers'
      page.should have_selector('div.pagination')
      click_link '2'
      test_navbar('My Followers', 'active')
      test_table(@follower)
    end

    it 'displays follower address if available' do
      user.contacts.create
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'active'
      visit favorite_sellers_path(ftype: 'seller', id: seller.id, status: 'active')
      test_navbar('My Followers', 'active')
      test_table(user, true)
    end
  end

  describe 'Manage Followers' do
    def test_table(has_addr=false)
      addr = has_addr ? seller.primary_address : seller.home_zip
      page.should have_content 'Seller Name'
      page.should have_content 'Location'
      page.should have_content '# Active Pixis'
      page.should have_content '# Current Followers'
      page.should have_css 'img'
      page.should have_content seller.business_name
      page.should have_content addr
      page.should have_content seller.listings.count
      page.should have_content seller.followers.count
      page.should have_content('View')
    end

    before :each do
      init_setup user
    end

    it 'renders Active' do
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'active'
      visit favorite_sellers_path(ftype: 'buyer', status: 'active')
      test_navbar('Manage Followers', 'active')
      test_table
      page.should have_content 'Displaying ' << FavoriteSeller.count.to_s << ' sellers'
    end

    it 'renders Inactive' do
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'removed'
      visit favorite_sellers_path(ftype: 'buyer', status: 'removed')
      test_navbar('Manage Followers', 'removed')
      test_table
      page.should have_content 'Displaying ' << FavoriteSeller.count.to_s << ' sellers'
    end

    it 'renders "No sellers found" if no sellers' do
      visit favorite_sellers_path(ftype: 'buyer', status: 'active')
      test_navbar('Manage Followers', 'active')
      page.should have_content 'No followed sellers found.'
    end

    it 'splits more than 15 entries into separate pages' do
      ('a'..'z').each do |char|
        business = create :contact_user, user_type_code: 'BUS', business_name: 'business ' + char
        create :favorite_seller, user_id: user.id, seller_id: business.id, status: 'active'
      end
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'active'
      visit favorite_sellers_path(ftype: 'buyer', status: 'active')
      page.should have_content 'Displaying sellers'
      page.should have_selector('div.pagination')
      click_link '2'
      test_navbar('Manage Followers', 'active')
      test_table
    end

    it 'displays seller address if available' do
      seller.contacts.create
      create :favorite_seller, user_id: user.id, seller_id: seller.id, status: 'active'
      visit favorite_sellers_path(ftype: 'buyer', status: 'active')
      test_navbar('Manage Followers', 'active')
      test_table(true)
    end
  end
end
