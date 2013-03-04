require 'spec_helper'

describe "UserSignins", :type => :feature do
  before { visit new_user_session_path }
  let(:user) { FactoryGirl.create :user }

  describe 'registered unconfirmed users' do 
    let(:submit) { "Sign in" }

    it "should display confirm message to a registered user" do
      fill_in "Email", :with => user.email
      fill_in "Password", :with => user.password
      click_button submit
      page.should have_content("You have to confirm your account before continuing") 
    end

    it "should not allow an unregistered user to sign in" do
      fill_in "Email", :with => "notarealuser@example.com"
      fill_in "Password", :with => "fakepassword"
      click_button submit
      page.should_not have_content("Signed in successfully")
    end
  end

  describe 'registered confirmed users' do
    before(:each) do
      login_as(user, :scope => :user, :run_callbacks => false)
      user.confirm!
    end

    it { should have_link('Sign out', href: destroy_user_session_path) }
    it { should_not have_link('Sign in', href: new_user_session_path) }
  end
end
