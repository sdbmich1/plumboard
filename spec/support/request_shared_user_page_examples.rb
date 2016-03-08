require 'spec_helper'

  def user_menu_items showFlg=false, sellerFlg=false, adminFlg=false
    expect(page).to have_button('Post')
    expect(page).to have_link('By You', href: new_temp_listing_path)
    expect(page).to have_link('By Us (PixiPost)', href: check_pixi_post_zips_path)
    if showFlg
      expect(page).to have_link('For Seller', href: new_temp_listing_path(pixan_id: @user))
      expect(page).to have_link('For Business', href: new_temp_listing_path(pixan_id: @user, ptype: 'bus'))
      expect(page).to have_link('PixiPosts', href: pixter_pixi_posts_path(status: 'scheduled')) unless adminFlg
    end
    expect(page).to have_link('My Pixis', href: seller_listings_path(status: 'active'))
    expect(page).to have_link('My Messages', href: conversations_path(status: 'received'))
    expect(page).to have_link('My Store', href: @user.local_user_path) unless adminFlg
    expect(page).to have_link('My Invoices', href: sent_invoices_path)
    expect(page).to have_link('My Accounts', href: new_bank_account_path)
    expect(page).to have_link('My Settings', href: user_path(@user))
    if sellerFlg
      expect(page).to have_link('My Followers', href: favorite_sellers_path(ftype: 'seller', id: @user.id, status: 'active'))
    else
      expect(page).to have_link('My Sellers', href: favorite_sellers_path(ftype: 'buyer', id: @user.id, status: 'active'))
    end
    expect(page).to have_link('My PixiPosts', href: seller_pixi_posts_path(status: 'active'))
    expect(page).to have_link('Sign out', href: destroy_user_session_path)
    expect(page).not_to have_link('Sign in', href: new_user_session_path)
  end

  def has_access? name
    name.match(/admin|editor|pixter/).nil?
  end

  def admin_pages stype
    page.send(stype, have_link('Accounts', href: card_accounts_path(adminFlg: true)))
    page.send(stype, have_link('Sites', href: sites_path(stype: 'region', status: 'active')))
    page.send(stype, have_link('Categories', href: manage_categories_path(status: 'active')))
    page.send(stype, have_link('Transactions', href: transactions_path))
    page.send(stype, have_link('Users', href: users_path))
  end

  def set_acct factory
    if factory == 'contact_user'
      @user = create factory.to_sym, user_type_code: 'BUS', business_name: 'Rhythm Music'
    else
      @user = create factory.to_sym, confirmed_at: Time.now 
    end
  end

shared_examples 'user_show_pages' do |name, type, url, flg, done_flg|
  describe 'show user page' do
    it 'renders show page' do
      expect(page).to have_content name
      expect(page).to have_content 'Facebook Login' if done_flg
      expect(page).to have_content 'Member Since'
      expect(page).to have_content 'Type'
      expect(page).to have_content type
      expect(page).to have_content 'URL'
      expect(page).to have_content url
      expect(page).to have_selector('#usr-edit-btn', visible: flg) if done_flg
      expect(page).to have_selector('#usr-done-btn', visible: flg) if done_flg
    end
  end
end

shared_examples 'an omniauth login' do |val, title|
  describe 'user log on' do
    scenario 'signs-in from sign-in page' do
      omniauth
      set_const val
      click_on "fb-btn"
      expect(page).to have_link('Sign out', href: destroy_user_session_path)
      expect(page).to have_content "#{title}"
        # page.should have_content "Welcome to Pixiboard, Bob!"
        # page.should have_content "To get a better user experience"
    end
  end
end

shared_examples 'manage_signin_links' do |factory, accessFlg, showFlg, sellerFlg, adminFlg|
  describe 'show user page' do
    before(:each) do
      set_acct factory
      user_login @user
    end
    it 'toggles manage links' do
      stype = accessFlg ? 'should' : 'should_not'
      expect(page).to have_content(@user.first_name)
      expect(page).to have_link('Sign out', href: destroy_user_session_path)
      page.send(stype, have_content('Manage')) if has_access? factory
      page.send(stype, have_link('Pixis', href: listings_path(status: 'active')))
      page.send(stype, have_link('PixiPosts', href: pixi_posts_path(status: 'active')))
      page.send(stype, have_link('Inquiries', href: inquiries_path(ctype: 'inquiry')))
      page.send(stype, have_link('Followers', href: favorite_sellers_path(ftype: 'buyer', status: 'active')))
      admin_pages stype if factory == 'admin'
      user_menu_items showFlg, sellerFlg, adminFlg
    end

    it "displays sign in link after signout" do
      click_link "Sign out"
      expect(page).to have_content 'How It Works'
    end
  end
end
