require 'spec_helper'

describe "Pages" do
  subject { page }

  describe "Home page" do

    before do
      FactoryGirl.create :pixi_point, code: 'act'
      FactoryGirl.create :pixi_point, code: 'lb'
      @user = FactoryGirl.create(:contact_user) 
      @pixi_user = FactoryGirl.create(:contact_user, first_name: 'Les', last_name: 'Flynn', email: 'lflynn@pixitest.com') 
      @temp_listing = FactoryGirl.create(:temp_listing, title: "Guitar", description: "Lessons", seller_id: @user.id ) 
      @listing = FactoryGirl.create(:listing, title: "Guitar", description: "Lessons", seller_id: @user.id, pixi_id: @temp_listing.pixi_id) 
      FactoryGirl.create(:listing, title: "Wicker Chair", description: "cool chair for sale", seller_id: @user.id) 
      FactoryGirl.create(:listing, title: "Wood Coffee Table", description: "cool table for sale", seller_id: @pixi_user.id) 
      visit root_path 
    end

    it { should have_selector('title', text: full_title('')) }
    it { should_not have_selector('title', text: '| Home') }
    it { should have_link 'How It Works', href: '#' }
    it { should have_link 'Help', href: '#' }
    it { should have_button 'Sign in' }
    it { should have_link 'Sign up for free!', href: new_user_registration_path }
    it { should have_link '', href: user_omniauth_authorize_path(:facebook) }
    it { should have_selector('h4', :text => 'Recent Pixis') }
    it { should have_content(@listing.title) }
    it { should have_content('Wicker Chair') }
    it { should have_content('Wood Coffee Table') }
    it { should have_selector('h4', :text => "Today's Leaderboard") }

    def user_login
      fill_in "user_email", :with => @user.email
      fill_in "user_password", :with => @user.password
      click_button 'Sign in'
    end

    it 'add user to leaderboard' do
      user_login
      sleep 2;
      page.should have_link('Sign out', href: destroy_user_session_path)

      click_link 'Sign out'
      page.should have_content(@user.name) 
      page.should have_content('points') 
    end

    it "clicks on a pixi" do
      click_link @listing.title
      page.should have_content "Sign in" 

      user_login
      page.should have_content @listing.title
      page.should have_content @listing.seller_name
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
