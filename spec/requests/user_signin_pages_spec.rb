require 'spec_helper'

describe "UserSignins", :type => :feature do
  before { visit new_user_session_path }

  let(:user) { FactoryGirl.create :user }
  let(:submit) { "Sign in" }

  it "should allow a registered user to sign in" do
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
