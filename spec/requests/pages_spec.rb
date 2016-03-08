require 'spec_helper'

describe "Pages" do
  let(:user) { FactoryGirl.create(:pixi_user) }
  let(:site) { FactoryGirl.create :site }
  subject { page }

  describe "Home page" do
    before :each do
      create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id ) 
      @loc = site.id
    end

    it 'shows content' do
      set_const 0
      visit root_path 
      expect(page).to have_selector('title', text: full_title(''))
      expect(page).not_to have_selector('title', text: '| Home')
      expect(page).to have_selector('#white-browse-home', href: local_listings_path(loc: @loc))
      expect(page).to have_link 'How It Works', href: howitworks_path
      expect(page).to have_link 'Help', href: help_path
      expect(page).to have_link 'Login', href: '#loginDialog'
      expect(page).to have_link 'Signup', href: '#signupDialog'
      expect(page).to have_link 'Forgot password?'
      expect(page).to have_link 'We Post', href: check_pixi_post_zips_path
      expect(page).to have_link 'You Post', href: new_temp_listing_path
      expect(page).to have_link 'View More >' #, href: local_listings_path(loc: @loc)
      expect(page).to have_link 'Learn More', href: '/howitworks#pxpay'
      expect(page).to have_link 'About', href: about_path
      expect(page).to have_link 'Privacy', href: privacy_path
      expect(page).to have_link 'Terms', href: terms_path
      expect(page).to have_link 'Contact', href: contact_path
      expect(page).to have_link 'Careers', href: career_path
      expect(page).to have_link 'PixiChat', href: '/howitworks#pxboard'
      expect(page).to have_link 'PixiPay', href: '/howitworks#pxpay'
      expect(page).to have_link 'PixiPost', href: '/howitworks#pxpost'
      expect(page).to have_selector('#fb-link', href: 'https://www.facebook.com/pixiboard')
      expect(page).to have_selector('#tw-link', href: 'https://twitter.com/pixiboardmagic')
      expect(page).to have_selector('#pi-link', href: 'http://www.pinterest.com/pixiboardmagic/')
      expect(page).to have_selector('#ins-link', href: 'http://instagram.com/pixiboardmagic')
      expect(page).to have_selector('#blog-link', href: 'http://www.pixiboardmagic.blogspot.com')
    end

    it 'changes Browse path' do
      set_const 500
      visit root_path 
      expect(Listing.active.count).to eq(1)
      sleep 2
      expect(page).not_to have_link 'Giveaway Rules', href: giveaway_path
      expect(page).to have_selector('#white-browse-home', href: local_listings_path(loc: @loc))
    end
  end

  describe "Signed In Users" do 
    before(:each) do
      pixi_user = create(:pixi_user, email: 'jsnow@pxtest.com') 
      init_setup pixi_user
      visit help_path 
    end

    it 'shows content' do
      expect(page).not_to have_link 'Sign Up', href: new_user_registration_path
      expect(page).not_to have_link 'Sign In', href: new_user_session_path
      expect(page).not_to have_link 'Forgot password?'
    end
  end

  describe "Help page" do
    before { visit help_path }
    it 'shows content' do
      expect(page).to have_link 'Sign Up', href: new_user_registration_path
      expect(page).to have_link 'Sign In', href: new_user_session_path
      expect(page).not_to have_link 'Forgot password?'
      expect(page).to have_selector('title', :text => full_title('Help'))
      expect(page).to have_selector('.section-hdr',    text: 'PixiPonders')
      expect(page).to have_selector('.site-logo', href: root_path)
      expect(page).to have_link 'here!', href: contact_path(source: 'support')
      expect(page).not_to have_selector('#browse-home', href: categories_path(loc: @loc))
    end
  end

  describe "About page" do
    before { visit about_path }
    it 'shows content' do
      expect(page).to have_link 'Sign Up', href: new_user_registration_path
      expect(page).to have_link 'Sign In', href: new_user_session_path
      expect(page).not_to have_link 'Forgot password?'
      expect(page).to have_selector('.site-logo', href: root_path)
      expect(page).to have_selector('.section-hdr',    text: 'About Us')
      expect(page).to have_selector('title', text: full_title('About Us'))
      expect(page).to have_link 'How It Works', href: howitworks_path
      expect(page).to have_link 'Help', href: help_path
      expect(page).not_to have_selector('#browse-home', href: categories_path(loc: @loc))
    end
  end

  describe "Terms page" do
    before { visit terms_path }
    it 'shows content' do
      expect(page).to have_link 'Sign Up', href: new_user_registration_path
      expect(page).to have_link 'Sign In', href: new_user_session_path
      expect(page).not_to have_link 'Forgot password?'
      expect(page).to have_selector('.site-logo', href: root_path)
      expect(page).to have_selector('title', text: full_title('Terms'))
      expect(page).not_to have_selector('#browse-home', href: categories_path(loc: @loc))
    end
  end

  describe "Privacy page" do
    before { visit privacy_path } 
    it 'shows content' do
      expect(page).to have_link 'Sign Up', href: new_user_registration_path
      expect(page).to have_link 'Sign In', href: new_user_session_path
      expect(page).not_to have_link 'Forgot password?'
      expect(page).to have_selector('.site-logo', href: root_path)
      expect(page).to have_selector('title', text: full_title('Privacy'))
      expect(page).not_to have_selector('#browse-home', href: categories_path(loc: @loc))
    end
  end

  describe 'user opens privacy page' do
    before do
      login_as(user, :scope => :user, :run_callbacks => false)
      @user = user
      visit privacy_path 
    end

    it 'shows content' do
      expect(page).not_to have_link 'Sign Up', href: new_user_registration_path
      expect(page).not_to have_link 'Sign In', href: new_user_session_path
      expect(page).to have_selector('.site-logo', href: root_path)
      expect(page).to have_selector('title', text: full_title('Privacy'))
      expect(page).not_to have_selector('#browse-home', href: categories_path(loc: @loc))
    end
  end

  describe "How It Works page" do
    before { visit howitworks_path }
    it 'shows content' do
      expect(page).to have_link 'Sign Up', href: new_user_registration_path
      expect(page).to have_link 'Sign In', href: new_user_session_path
      expect(page).not_to have_link 'How It Works', href: howitworks_path
      expect(page).not_to have_link 'Forgot password?'
      expect(page).to have_selector('.site-logo', href: root_path)
      expect(page).to have_selector('.section-hdr',    text: 'How It Works')
      expect(page).to have_selector('title', text: full_title('How It Works'))
      expect(page).to have_selector('.pxb-img', visible: true)
      expect(page).to have_selector('.vimeo-thumb', visible: true)
      expect(page).not_to have_selector('#browse-home', href: categories_path(loc: @loc))
    end
  end
end
