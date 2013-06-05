require 'spec_helper'

describe "Settings", :type => :feature do
  subject { page }
  let(:user) { FactoryGirl.create(:pixi_user) }

  before(:each) do
    login_as(user, :scope => :user, :run_callbacks => false)
    @user = user
  end

  describe "GET /settings" do
    it "should display settings" do 
      visit settings_path  
      page.should have_content("Profile")
    end
  end

  describe 'View setting page via click' do
    it 'should show settings page' do
      visit root_path 
      click_link 'Settings'
      page.should have_content("Profile")
    end
  end

  describe 'View contact setting page via click' do
    before { visit settings_path }
    it 'should show contact page', js: true do
      click_link 'Contact'
      page.should have_content("Home Phone")
    end
  end

  describe 'View change password setting page via click' do
    before { visit settings_path }
    it 'should show contact page', js: true do
      click_link 'Change Password'
      page.should have_content("Change Password")
    end
  end
end
