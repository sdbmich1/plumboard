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
    it { should have_link 'Help', href: '#' }
    it { should have_button 'Sign in' }
    it { should have_link 'Sign up for free!', href: new_user_registration_path }
    it { should have_link 'Sign in with', href: user_omniauth_authorize_path(:facebook) }
    it { should have_link '', href: categories_path }
    it { should have_link 'About', href: '#' }
    it { should have_link 'Privacy', href: '#' }
    it { should have_link 'Contact', href: '#' }
  end

  describe "Browse Stuff" do

    before do
      @user = FactoryGirl.create(:contact_user) 
      @pixi_user = FactoryGirl.create(:contact_user, first_name: 'Les', last_name: 'Flynn', email: 'lflynn@pixitest.com') 
      @category = FactoryGirl.create :category
      FactoryGirl.create :category, name: 'Computer', category_type: 'sales', status: 'active'
      FactoryGirl.create :category, name: 'Stuff', category_type: 'sales', status: 'inactive'
      FactoryGirl.create(:listing, title: "Wicker Chair", description: "cool chair for sale", seller_id: @user.id, category_id: @category.id) 
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

    it "clicks on a category" do
      find("#browse-link").click
      click_link @category.name_title
      page.should have_content 'Pixis'
      page.should have_content @listing.nice_title
      page.should have_content @listing.seller_name
    end

    it "clicks on a pixi" do
      find("#browse-link").click
      click_link @category.name_title
      click_link @listing.nice_title
      page.should have_content "Sign in" 
      user_login
      page.should have_content @listing.nice_title
      page.should have_content 'Comments'
    end
  end

  describe "Help page" do
    before { visit help_path }
    it { should have_selector('h1', text: 'Help') }
    it { should have_selector('title', :text => full_title('Help')) }
  end

  describe "About page" do
    before { visit about_path }
    it { should have_selector('h1',    text: 'About Us') }
    it { should have_selector('title', text: full_title('About Us')) }
  end

  describe "Contact page" do
    before { visit contact_path }
    it { should have_selector('h1',    text: 'Contact') }
    it { should have_selector('title', text: full_title('Contact')) }
  end

  describe "Privacy page" do
    before { visit privacy_path } 
    it { should have_selector('h1',    text: 'Privacy') }
    it { should have_selector('title', text: full_title('Privacy')) }
  end
end
