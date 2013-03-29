require 'spec_helper'

describe "UserRegistrations", :type => :feature do
  subject { page }

  describe 'allows a user to register' do
    let(:submit) { "Register" } 

    describe "with invalid information" do
      it "should not create a user" do
        expect{ 
		visit new_user_registration_path 
		click_button submit 
	}.not_to change(User, :count)
      end
    end

    def user_data
        fill_in "First name", with: 'New'
        fill_in "Last name", with: 'User'
        fill_in 'Email', :with => 'newuser@example.com'
	select('Male', :from => 'Gender')
	select('January', :from => "user_birth_date_2i")
	select('10', :from => 'user_birth_date_3i')
	select('1983', :from => 'user_birth_date_1i')
        fill_in 'Password', :with => 'userpassword'
        fill_in "Confirmation", with: 'userpassword'
    end

    describe "create user" do
      before(:each) do
        visit root_path
        click_link 'Sign up now!'
	user_data
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
        page.should have_content 'A message with a confirmation link has been sent to your email address' 
      end	
    end

  end  
end
