require 'spec_helper'

feature "UserSignins" do
  subject { page }
  let(:submit) { "Sign in" }
  before { visit new_user_session_path }

  def user_login
    fill_in "Email", :with => user.email
    fill_in "Password", :with => user.password
    click_button submit
  end

  describe 'registered unconfirmed users' do 
    let(:user) { FactoryGirl.create :user }

    it "should display confirm message to a registered user" do
      user_login
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
    let(:user) { FactoryGirl.create :user, confirmed_at: Time.now }
    before(:each) do
      user_login
      @user = user
    end

    it { should have_link('Profile', href: user_path(user)) }
    it { should have_link('Sign out', href: destroy_user_session_path) }
    it { should_not have_link('Orders', href: pending_listings_path) }
    it { should_not have_link('Transactions', href: transactions_path) }
    it { should_not have_content('Dashboard') }
    it { should_not have_link('Users', href: users_path) }
    it { should_not have_link('Sign in', href: new_user_session_path) }

    describe "followed by signout" do
      before { click_link "Sign out" }
      it { should have_link('Sign in', href: new_user_session_path) }
    end
  end

  describe 'registered admin users' do
    let(:user) { FactoryGirl.create :admin, confirmed_at: Time.now }
    before(:each) do
      user_login
      @user = user
    end

    it { should have_content('Manage') }
    it { should have_link('Pending Orders', href: pending_listings_path) }
    it { should have_link('Transactions', href: transactions_path) }
    it { should have_link('Users', href: users_path) }
    it { should have_content('Dashboard') }
    it { should have_link('Sign out', href: destroy_user_session_path) }
    it { should_not have_link('Sign in', href: new_user_session_path) }

    describe "followed by signout" do
      before { click_link "Sign out" }
      it { should have_link('Sign in', href: new_user_session_path) }
    end
  end

  describe 'registered editor users' do
    let(:user) { FactoryGirl.create :editor, confirmed_at: Time.now }
    before(:each) do
      user_login
      @user = user
    end

    it { should have_content('Manage') }
    it { should have_link('Pending Orders', href: pending_listings_path) }
    it { should_not have_link('Transactions', href: transactions_path) }
    it { should_not have_link('Users', href: users_path) }
    it { should have_content('Dashboard') }
    it { should have_link('Sign out', href: destroy_user_session_path) }
    it { should_not have_link('Sign in', href: new_user_session_path) }

    describe "followed by signout" do
      before { click_link "Sign out" }
      it { should have_link('Sign in', href: new_user_session_path) }
    end
  end

  describe 'registered subscriber users' do
    let(:user) { FactoryGirl.create :subscriber, confirmed_at: Time.now }
    before(:each) do
      user_login
      @user = user
    end

    it { should_not have_content('Manage') }
    it { should_not have_link('Pending Orders', href: pending_listings_path) }
    it { should_not have_link('Transactions', href: transactions_path) }
    it { should_not have_link('Users', href: users_path) }
    it { should have_content('Dashboard') }
    it { should have_link('Sign out', href: destroy_user_session_path) }
    it { should_not have_link('Sign in', href: new_user_session_path) }

    describe "followed by signout" do
      before { click_link "Sign out" }
      it { should have_link('Sign in', href: new_user_session_path) }
    end
  end

end
