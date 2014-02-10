require 'spec_helper'

describe "Pages" do
  subject { page }

  describe "Home page" do

    before do
      visit root_path 
    end

    it { should have_selector('title', text: full_title('')) }
    it { should_not have_selector('title', text: '| Home') }
    it { should have_link 'How It Works', href: '#' }
    it { should have_link 'Help', href: help_path }
    it { should have_button 'Sign in' }
    it { should have_link 'Sign up for free!', href: new_user_registration_path }
    it { should have_link 'Sign in via', href: user_omniauth_authorize_path(:facebook) }
    it { should have_selector '#browse-link', href: categories_path }
    it { should have_link 'About', href: about_path }
    it { should have_link 'Privacy', href: privacy_path }
    it { should have_link 'Terms of Service', href: '#' }
    it { should have_link 'Contact', href: contact_path }
    it { should have_selector('#fb-link', href: 'https://www.facebook.com/pages/Pixiboard/628604560511266') }
    it { should have_selector('#tw-link', href: 'https://twitter.com/doyoupixi') }
    it { should have_selector('#pi-link', href: 'http://www.pinterest.com/pixiboardmagic/') }
    it { should have_selector('#ins-link', href: 'http://instagram.com/pixiboard') }
  end

  describe "Browse Stuff" do

    before do
      @user = FactoryGirl.create(:contact_user) 
      @pixi_user = FactoryGirl.create(:contact_user, first_name: 'Les', last_name: 'Flynn', email: 'lflynn@pixitest.com') 
      @category = FactoryGirl.create :category
      @listing = FactoryGirl.create(:listing, title: "Wicker Chair", description: "cool chair for sale", seller_id: @user.id, category_id: @category.id) 
      FactoryGirl.create :category, name: 'Computer', category_type: 'sales', status: 'active'
      FactoryGirl.create :category, name: 'Stuff', category_type: 'sales', status: 'inactive'
      FactoryGirl.create(:listing, title: "Wood Coffee Table", description: "cool table for sale", seller_id: @pixi_user.id) 
      visit root_path 
    end

    it 'browses categories' do
      find("#browse-link").click
      page.should have_content('Home') 
      page.should have_content(@category.name_title) 
      page.should have_content('Computer') 
    end

    def user_login
      fill_in "user_email", :with => @user.email
      fill_in "user_password", :with => @user.password
      click_button 'Sign in'
      sleep 2;
    end

    it "clicks on a category and prompts to sign up" do
      find("#browse-link").click
      click_link @category.name_title
      page.should have_content "You need to sign in or sign up before continuing." 
    end

    it "clicks on a category and logs in" do
      find("#browse-link").click
      click_link @category.name_title
      page.should have_content "Sign in" 
      user_login
      page.should have_content 'Pixis'
      page.should have_content @category.name_title
      page.should have_content @listing.nice_title
    end
  end

  describe "Help page" do
    before { visit help_path }
    it { should have_selector('h1', text: 'Help') }
    it { should have_selector('title', :text => full_title('Help')) }
  end

  describe "About page" do
    before { visit about_path }
    it { should have_selector('.section-hdr',    text: 'About Us') }
    it { should have_selector('title', text: full_title('About Us')) }
    it { should have_link 'How It Works', href: '#' }
    it { should have_link 'Help', href: help_path }
    it { should have_selector('.site-logo', href: root_path) }
  end

  describe "Contact page" do
    before { visit contact_path }
    it { should have_selector('.section-hdr',    text: 'Contact') }
    it { should have_selector('title', text: full_title('Contact')) }
  end

  describe "Privacy page" do
    before { visit privacy_path } 
    it { should have_selector('h1',    text: 'Privacy') }
    it { should have_selector('title', text: full_title('Privacy')) }
  end
end
