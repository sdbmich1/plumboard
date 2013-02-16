require 'spec_helper'

describe "Users" do
  describe "GET /users" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get users_path
      response.status.should be(200)
    end
  end
  
  describe "Manage users" do 
    describe "User registration" do
      it 'allows a user to register' do
        visit new_user_registration_path
        fill_in 'First name', :with => 'New'
	fill_in 'Last name', :with => 'User'
	fill_in 'Email', :with => 'newuser@example.com'
        fill_in 'Password', :with => 'userpassword'
	fill_in 'Confirmation', :with => 'userpassword'
	click_button 'Register'
	page.should have content 'Welcome'
      end
    end
  end
end
