require 'spec_helper'

describe "Pages" do
  let(:user) { FactoryGirl.create(:pixi_user) }
  subject { page }

  def init_setup usr
    login_as(usr, :scope => :user, :run_callbacks => false)
    @user = usr
  end

  describe "Home page" do
    before { visit root_path }
    it 'shows content' do
      page.should have_selector('title', text: full_title(''))
      page.should_not have_selector('title', text: '| Home')
      page.should_not have_link 'Sign Up', href: new_user_registration_path
      page.should have_content 'Already have an account?'
      page.should have_link 'Sign In', href: new_user_session_path
      page.should have_link 'Browse', href: categories_path
      page.should have_link 'Forgot password?'
      page.should have_link 'How It Works', href: howitworks_path
      page.should have_link 'Help', href: help_path
      page.should_not have_button 'Sign in'
      page.should_not have_link 'Sign up for free!', href: new_user_registration_path
      page.should have_link 'Connect via email', href: new_user_registration_path
      page.should have_link 'Connect via', href: user_omniauth_authorize_path(:facebook)
      page.should have_link 'About', href: about_path
      page.should have_link 'Privacy', href: privacy_path
      page.should have_link 'Terms', href: terms_path
      page.should have_link 'Contact', href: contact_path
      page.should have_selector('#fb-link', href: 'https://www.facebook.com/pixiboard')
      page.should have_selector('#tw-link', href: 'https://twitter.com/pixiboardmagic')
      page.should have_selector('#pi-link', href: 'http://www.pinterest.com/pixiboardmagic/')
      page.should have_selector('#ins-link', href: 'http://instagram.com/pixiboard')
    end
  end

  describe "Browse Stuff" do
    before do
      @user = create(:contact_user) 
      @pixi_user = create(:contact_user, first_name: 'Les', last_name: 'Flynn', email: 'lflynn@pixitest.com') 
      @category = create :category
      @listing = create(:listing, title: "Wicker Chair", description: "cool chair for sale", seller_id: @user.id, category_id: @category.id) 
      create :category, name: 'Computer', category_type: 'sales', status: 'active'
      create :category, name: 'Stuff', category_type: 'sales', status: 'inactive'
      create(:listing, title: "Wood Coffee Table", description: "cool table for sale", seller_id: @pixi_user.id) 
      visit root_path 
    end

    it 'browses categories' do
      find_link('Browse').click
      page.should have_content('Home') 
      page.should have_content(@category.name_title) 
      page.should have_content('Computer') 
    end

    it "clicks on a category and logs in" do
      find_link('Browse').click
      click_link @category.name_title
      page.should have_content 'Pixis'
      page.should have_content @category.name_title
      page.should have_content @listing.nice_title
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
      page.should_not have_link 'Browse', href: categories_path
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
      page.should_not have_link 'Browse', href: categories_path
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
      page.should_not have_link 'Browse', href: categories_path
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
      page.should_not have_link 'Browse', href: categories_path
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
      page.should_not have_link 'Browse', href: categories_path
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
      page.should_not have_link 'Browse', href: categories_path
    end
  end
end
