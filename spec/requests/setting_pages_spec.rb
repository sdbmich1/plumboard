require 'spec_helper'

describe "Settings", :type => :feature do
  subject { page }
  let(:user) { FactoryGirl.create(:pixi_user) }

  describe "GET /settings" do
    before :each do
      init_setup user
      visit "/users/#{@user.id}"
    end

    it "should display settings menu" do 
      page.should have_content("Settings")
      page.should have_link("Account", href: "/users/#{@user.id}")
      page.should have_link("Profile", href: settings_path)
      page.should have_link("Contact", href: settings_contact_path)
      page.should have_link("Password", href: settings_password_path)
    end

    it 'should show account page' do
      page.should have_content("#{@user.name}")
      page.should have_content("Pixis Posted")
      page.should have_content("Member Since")
      page.should have_content("URL")
      page.should have_content("#{@user.user_url}")
    end

    it 'should show profile page', js: true do
      click_link 'Profile'
      page.should have_selector("#user_first_name")
      page.should have_selector('#usr_photo')
    end

    it 'should show contact page', js: true do
      click_link 'Contact'
      page.should have_content("Home Phone")
    end

    it 'should show contact page', js: true do
      click_link 'Password'
      page.should have_content("Password")
    end
  end
end
