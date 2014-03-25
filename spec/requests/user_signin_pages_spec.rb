require 'spec_helper'

feature "UserSignins" do
  let(:submit) { "Sign in" }
  subject { page }

  def user_login
    fill_in "user_email", :with => @user.email
    fill_in "pwd", :with => @user.password
    click_button submit
  end

  def invalid_login
    fill_in "user_email", :with => "notarealuser@example.com"
    fill_in "pwd", :with => "fakepassword"
    click_button submit
  end

  describe 'home page' do 
    before do 
      @user = FactoryGirl.create :pixi_user, confirmed_at: Time.now 
      visit root_path
    end

    it "signs in a registered user" do
      user_login
      page.should have_content "Home"
    end

    it "does not sign in a unregistered user" do
      invalid_login
      page.should_not have_content "Home"
      page.should have_content "Sign in"
    end
  end

  describe 'sign in page' do 
    before { visit new_user_session_path }

    it 'shows content' do
      page.should have_selector '#fb-btn', href: user_omniauth_authorize_path(:facebook)
      page.should have_button('Sign in')
      page.should have_link 'Sign up for free!', href: new_user_registration_path
    end

    describe 'facebook' do 
      before :each do
        OmniAuth.config.add_mock :facebook,
          uid: "fb-12345", info: { name: "Bob Smith", image: "http://graph.facebook.com/708798320/picture?type=square" },
          extra: { raw_info: { first_name: 'Bob', last_name: 'Smith',
          email: 'bob.smith@test.com', birthday: "01/03/1989", gender: 'male' } } 
      end

      scenario 'signs-in from sign-in page' do
        click_on "fb-btn"
        page.should have_link('Sign out', href: destroy_user_session_path)
        page.should have_content "Home"
        page.should have_content "Welcome to Pixiboard, Bob!"
        page.should have_content "To get a better user experience"

	click_on 'Sign out'
        page.should have_link "Browse"
        click_on "fb-btn"
        page.should have_content "Home"
        page.should_not have_content "Welcome to Pixiboard, Bob!"
        page.should_not have_content "To get a better user experience"
      end

      scenario 'signs-in from home page' do
        expect {
          visit root_path
          click_on "fb-btn"
        }.to change(User, :count).by(1)

        page.should have_link('Sign out', href: destroy_user_session_path)
        page.should have_content "Home"
      end
    end

    describe 'registered unconfirmed users' do 
      before do
        @user = FactoryGirl.create :unconfirmed_user, confirmed_at: nil 
      end

      it "displays confirm message to a registered user" do
        user_login
        page.should have_content("You have to confirm your account before continuing") 
      end

      it "does not allow an unregistered user to sign in" do
        invalid_login
        page.should_not have_content("Signed in successfully")
      end
    end

    describe 'registered confirmed users' do
      before(:each) do
        @user = FactoryGirl.create :pixi_user, confirmed_at: Time.now 
        user_login
      end

      it 'shows content' do
        page.should have_content(@user.first_name)
        page.should have_link('Sign out', href: destroy_user_session_path)
        page.should_not have_link('Orders', href: pending_listings_path)
        page.should_not have_link('Transactions', href: transactions_path)
        page.should_not have_link('PixiPosts', href: pixi_posts_path)
        page.should_not have_link('Users', href: users_path)
        page.should_not have_link('Inquiries', href: inquiries_path(ctype: 'inquiry'))
        page.should have_button('Post')
        page.should have_link('By You', href: new_temp_listing_path)
        page.should have_link('By Us', href: check_pixi_post_zips_path)
        page.should_not have_link('For Seller', href: new_temp_listing_path(pixan_id: @user))
        page.should have_link('My Pixis', href: seller_listings_path)
        page.should have_link('My Messages', href: posts_path)
        page.should have_link('My Invoices', href: invoices_path)
        page.should have_link('My Accounts', href: new_bank_account_path)
        page.should have_link('My Settings', href: settings_path)
        page.should have_link('My PixiPosts', href: seller_pixi_posts_path(status: 'active'))
        page.should_not have_link('Sign in', href: new_user_session_path)
        page.should have_content "Welcome to Pixiboard, #{@user.first_name}!"
        page.should_not have_content "To get a better user experience"

	visit new_temp_listing_path
        page.should_not have_content "Home"
        page.should have_content "Build Your Pixi"

	visit root_path
        page.should have_content "Home"
        page.should_not have_content "Welcome to Pixiboard"

	click_on 'Sign out'
        page.should have_link "Browse"
	user_login
        page.should have_content "Home"
        page.should_not have_content "Welcome to Pixiboard"
      end

      it "displays sign in link after signout" do
        click_link "Sign out"
        page.should have_content 'How It Works'
      end
    end

    describe 'registered admin users' do
      before(:each) do
        @user = FactoryGirl.create :admin, confirmed_at: Time.now 
        user_login
      end

      it 'shows content' do
        page.should have_content(@user.first_name)
        page.should have_content('Manage')
        page.should have_link('Pending Orders', href: pending_listings_path(status: 'pending'))
        page.should have_link('PixiPosts', href: pixi_posts_path(status: 'active'))
        page.should have_link('Inquiries', href: inquiries_path(ctype: 'inquiry'))
        page.should have_link('Categories', href: manage_categories_path)
        page.should have_link('Transactions', href: transactions_path)
        page.should have_link('Users', href: users_path)
        page.should have_button('Post')
        page.should have_link('By You', href: new_temp_listing_path)
        page.should have_link('By Us', href: check_pixi_post_zips_path)
        page.should have_link('For Seller', href: new_temp_listing_path(pixan_id: @user))
        page.should have_link('My Pixis', href: seller_listings_path)
        page.should have_link('My Messages', href: posts_path)
        page.should have_link('My Invoices', href: invoices_path)
        page.should have_link('My Accounts', href: new_bank_account_path)
        page.should have_link('My Settings', href: settings_path)
        page.should have_link('My PixiPosts', href: seller_pixi_posts_path(status: 'active'))
        page.should have_link('Sign out', href: destroy_user_session_path)
        page.should_not have_link('Sign in', href: new_user_session_path)
      end

      it "displays sign in link after signout" do
        click_link "Sign out"
        page.should have_content 'How It Works'
      end
    end

    describe 'registered editor users' do
      before(:each) do
        @user = FactoryGirl.create :editor, confirmed_at: Time.now 
        user_login
      end

      it 'shows content' do
        page.should have_content(@user.first_name)
        page.should have_content('Manage')
        page.should have_link('Pending Orders', href: pending_listings_path(status: 'pending'))
        page.should have_link('PixiPosts', href: pixi_posts_path(status: 'active'))
        page.should have_link('Inquiries', href: inquiries_path(ctype: 'inquiry'))
        page.should_not have_link('Categories', href: manage_categories_path)
        page.should_not have_link('Transactions', href: transactions_path)
        page.should_not have_link('Users', href: users_path)
        page.should have_link('For Seller', href: new_temp_listing_path(pixan_id: @user))
        page.should have_link('My Pixis', href: seller_listings_path)
        page.should have_link('My Messages', href: posts_path)
        page.should have_link('My Invoices', href: invoices_path)
        page.should have_link('My Accounts', href: new_bank_account_path)
        page.should have_link('My Settings', href: settings_path)
        page.should have_link('My PixiPosts', href: seller_pixi_posts_path(status: 'active'))
        page.should have_link('Sign out', href: destroy_user_session_path)
        page.should_not have_link('Sign in', href: new_user_session_path)
      end

      it "displays sign in link after signout" do
        click_link "Sign out"
        page.should have_content 'How It Works'
      end
    end

    describe "displays my accounts link" do
      before(:each) do
        @user = FactoryGirl.create :subscriber, confirmed_at: Time.now 
        user_login
        FactoryGirl.create(:listing, seller_id: @user.id)
	@account = @user.bank_accounts.create FactoryGirl.attributes_for :bank_account, status: 'active'
	visit root_path
      end

      it 'shows content' do
        page.should have_content('My Accounts')
        page.should have_link('My Accounts', href: bank_account_path(@account))
      end
    end

    describe 'registered subscriber users' do
      before(:each) do
        @user = FactoryGirl.create :subscriber, confirmed_at: Time.now 
        user_login
      end

      it 'shows content' do
        page.should have_content(@user.first_name)
        page.should_not have_content('Manage')
        page.should_not have_link('PixiPosts', href: pixi_posts_path)
        page.should_not have_link('Inquiries', href: inquiries_path(ctype: 'inquiry'))
        page.should_not have_link('Pending Orders', href: pending_listings_path(status: 'pending'))
        page.should_not have_link('Categories', href: manage_categories_path)
        page.should_not have_link('Transactions', href: transactions_path)
        page.should_not have_link('Users', href: users_path)
        page.should have_link('My Pixis', href: seller_listings_path)
        page.should have_link('My Messages', href: posts_path)
        page.should have_link('My Invoices', href: invoices_path)
        page.should have_link('My Settings', href: settings_path)
        page.should have_link('My PixiPosts', href: seller_pixi_posts_path(status: 'active'))
        page.should have_link('Sign out', href: destroy_user_session_path)
        page.should_not have_link('Sign in', href: new_user_session_path)
      end

      it "displays sign in link after signout" do
        click_link "Sign out"
        page.should have_content 'How It Works'
      end
    end
  end

end
