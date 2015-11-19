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
      page.should have_selector('title', text: full_title(''))
      page.should_not have_selector('title', text: '| Home')
      page.should have_selector('#white-browse-home', href: local_listings_path(loc: @loc))
      page.should have_link 'How It Works', href: howitworks_path
      page.should have_link 'Help', href: help_path
      page.should have_link 'Login', href: '#loginDialog'
      page.should have_link 'Signup', href: '#signupDialog'
      page.should have_link 'Forgot password?'
      page.should have_link 'We Post', href: check_pixi_post_zips_path
      page.should have_link 'You Post', href: new_temp_listing_path
      page.should have_link 'View More >' #, href: local_listings_path(loc: @loc)
      page.should have_link 'Learn More', href: '/howitworks#pxpay'
      page.should have_link 'About', href: about_path
      page.should have_link 'Privacy', href: privacy_path
      page.should have_link 'Terms', href: terms_path
      page.should have_link 'Contact', href: contact_path
      page.should have_link 'Careers', href: career_path
      page.should have_link 'PixiChat', href: '/howitworks#pxboard'
      page.should have_link 'PixiPay', href: '/howitworks#pxpay'
      page.should have_link 'PixiPost', href: '/howitworks#pxpost'
      page.should have_selector('#fb-link', href: 'https://www.facebook.com/pixiboard')
      page.should have_selector('#tw-link', href: 'https://twitter.com/pixiboardmagic')
      page.should have_selector('#pi-link', href: 'http://www.pinterest.com/pixiboardmagic/')
      page.should have_selector('#ins-link', href: 'http://instagram.com/pixiboardmagic')
      page.should have_selector('#blog-link', href: 'http://www.pixiboardmagic.blogspot.com')
    end

    it 'changes Browse path' do
      set_const 500
      visit root_path 
      expect(Listing.active.count).to eq(1)
      sleep 2
      page.should_not have_link 'Giveaway Rules', href: giveaway_path
      page.should have_selector('#white-browse-home', href: local_listings_path(loc: @loc))
    end
  end

  describe "Signed In Users" do 
    before(:each) do
      pixi_user = create(:pixi_user, email: 'jsnow@pxtest.com') 
      init_setup pixi_user
      visit help_path 
    end

    it 'shows content' do
      page.should_not have_link 'Sign Up', href: new_user_registration_path
      page.should_not have_link 'Sign In', href: new_user_session_path
      page.should_not have_link 'Forgot password?'
    end
  end

  describe "Help page" do
    before { visit help_path }
    it 'shows content' do
      page.should have_link 'Sign Up', href: new_user_registration_path
      page.should have_link 'Sign In', href: new_user_session_path
      page.should_not have_link 'Forgot password?'
      page.should have_selector('title', :text => full_title('Help'))
      page.should have_selector('.section-hdr',    text: 'PixiPonders')
      page.should have_selector('.site-logo', href: root_path)
      page.should have_link 'here!', href: contact_path(source: 'support')
      page.should_not have_selector('#browse-home', href: categories_path(loc: @loc))
    end
  end

  describe "About page" do
    before { visit about_path }
    it 'shows content' do
      page.should have_link 'Sign Up', href: new_user_registration_path
      page.should have_link 'Sign In', href: new_user_session_path
      page.should_not have_link 'Forgot password?'
      page.should have_selector('.site-logo', href: root_path)
      page.should have_selector('.section-hdr',    text: 'About Us')
      page.should have_selector('title', text: full_title('About Us'))
      page.should have_link 'How It Works', href: howitworks_path
      page.should have_link 'Help', href: help_path
      page.should_not have_selector('#browse-home', href: categories_path(loc: @loc))
    end
  end

  describe "Terms page" do
    before { visit terms_path }
    it 'shows content' do
      page.should have_link 'Sign Up', href: new_user_registration_path
      page.should have_link 'Sign In', href: new_user_session_path
      page.should_not have_link 'Forgot password?'
      page.should have_selector('.site-logo', href: root_path)
      page.should have_selector('title', text: full_title('Terms'))
      page.should_not have_selector('#browse-home', href: categories_path(loc: @loc))
    end
  end

  describe "Privacy page" do
    before { visit privacy_path } 
    it 'shows content' do
      page.should have_link 'Sign Up', href: new_user_registration_path
      page.should have_link 'Sign In', href: new_user_session_path
      page.should_not have_link 'Forgot password?'
      page.should have_selector('.site-logo', href: root_path)
      page.should have_selector('title', text: full_title('Privacy'))
      page.should_not have_selector('#browse-home', href: categories_path(loc: @loc))
    end
  end

  describe 'user opens privacy page' do
    before do
      login_as(user, :scope => :user, :run_callbacks => false)
      @user = user
      visit privacy_path 
    end

    it 'shows content' do
      page.should_not have_link 'Sign Up', href: new_user_registration_path
      page.should_not have_link 'Sign In', href: new_user_session_path
      page.should have_selector('.site-logo', href: root_path)
      page.should have_selector('title', text: full_title('Privacy'))
      page.should_not have_selector('#browse-home', href: categories_path(loc: @loc))
    end
  end

  describe "How It Works page" do
    before { visit howitworks_path }
    it 'shows content' do
      page.should have_link 'Sign Up', href: new_user_registration_path
      page.should have_link 'Sign In', href: new_user_session_path
      page.should_not have_link 'How It Works', href: howitworks_path
      page.should_not have_link 'Forgot password?'
      page.should have_selector('.site-logo', href: root_path)
      page.should have_selector('.section-hdr',    text: 'How It Works')
      page.should have_selector('title', text: full_title('How It Works'))
      page.should have_selector('.pxb-img', visible: true)
      page.should have_selector('.vimeo-thumb', visible: true)
      page.should_not have_selector('#browse-home', href: categories_path(loc: @loc))
    end
  end
end
