require 'spec_helper'

feature "UserSignins" do
  let(:submit) { "Sign in" }
  before { visit new_user_session_path }
  subject { page }

  def user_login
    fill_in "user_email", :with => user.email
    fill_in "user_password", :with => user.password
    click_button submit
  end

  describe 'facebook' do 
    before :each do
      OmniAuth.config.add_mock :facebook,
        uid: "fb-12345", info: { name: "Bob Smith", image: "http://graph.facebook.com/708798320/picture?type=square" },
        extra: { raw_info: { first_name: 'Bob', last_name: 'Smith',
        email: 'bob.smith@test.com', birthday: "01/03/1989", gender: 'male' } } 
    end

    scenario 'should sign-in from sign-in page' do
      click_on "Sign in with Facebook"
      page.should have_link('Sign out', href: destroy_user_session_path)
      page.should have_content "Successfully authenticated from Facebook account"
    end

    scenario 'should sign-in from home page' do
      expect {
        visit root_path
        click_on "Sign up via Facebook"
      }.to change(User, :count).by(1)

      page.should have_link('Sign out', href: destroy_user_session_path)
      page.should have_content "Successfully authenticated from Facebook account"
    end
  end

  describe 'registered unconfirmed users' do 
    let(:user) { FactoryGirl.create :pixi_user, confirmed_at: nil }

    it "should display confirm message to a registered user" do
      user_login
      page.should have_content("You have to confirm your account before continuing") 
    end

    it "should not allow an unregistered user to sign in" do
      fill_in "user_email", :with => "notarealuser@example.com"
      fill_in "user_password", :with => "fakepassword"
      click_button submit
      page.should_not have_content("Signed in successfully")
    end
  end

  describe 'registered confirmed users' do
    let(:user) { FactoryGirl.create :pixi_user, confirmed_at: Time.now }
    before(:each) do
      user_login
      @user = user
    end

    it { should have_link('Profile', href: edit_user_path(user)) }
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
