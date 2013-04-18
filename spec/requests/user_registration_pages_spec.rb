require 'spec_helper'

feature "UserRegistrations" do
  subject { page }

  describe 'allows a user to register' do
    let(:submit) { "Register" } 

    def user_info
      fill_in "user_first_name", with: 'New'
      fill_in "user_last_name", with: 'User'
    end

    def user_birth_date
	select('1', :from => "user_birth_date_2i")
	select('10', :from => 'user_birth_date_3i')
	select('1983', :from => 'user_birth_date_1i')
    end

    describe "with invalid information" do
      it "should not create a empty user" do
        expect{ 
		visit new_user_registration_path 
		click_button submit 
	}.not_to change(User, :count)
      end

      it "should not create a incomplete user" do
        expect{ 
		visit new_user_registration_path 
		user_info
		click_button submit 
	}.not_to change(User, :count)
      end

      it "should not create user w/o email" do
        expect{ 
		visit new_user_registration_path 
		user_info
		user_birth_date
		select('Male', :from => 'user_gender')
        	fill_in 'user_password', :with => 'userpassword'
        	fill_in "user_password_confirmation", with: 'userpassword'
		click_button submit 
	}.not_to change(User, :count)
      end

      it "should not create user w/o gender" do
        expect{ 
		visit new_user_registration_path 
		user_info
		user_birth_date
        	fill_in 'user_email', :with => 'newuser@example.com'
        	fill_in 'user_password', :with => 'userpassword'
        	fill_in "user_password_confirmation", with: 'userpassword'
      		add_data_w_photo
		click_button submit 
	}.not_to change(User, :count)
      end

      it "should not create user w/o birthdate" do
        expect{ 
		visit new_user_registration_path 
		user_info
		select('Male', :from => 'user_gender')
        	fill_in 'user_email', :with => 'newuser@example.com'
        	fill_in 'user_password', :with => 'userpassword'
        	fill_in "user_password_confirmation", with: 'userpassword'
      		add_data_w_photo
		click_button submit 
	}.not_to change(User, :count)
      end

      it "should not create user w/o password" do
        expect{ 
		visit new_user_registration_path 
		user_info
		user_birth_date
		select('Male', :from => 'user_gender')
        	fill_in 'user_email', :with => 'newuser@example.com'
        	fill_in "user_password_confirmation", with: 'userpassword'
      		add_data_w_photo
		click_button submit 
	}.not_to change(User, :count)
      end

      it "should not create user w/o password confirmation" do
        expect{ 
		visit new_user_registration_path 
		user_info
		user_birth_date
		select('Male', :from => 'user_gender')
        	fill_in 'user_email', :with => 'newuser@example.com'
        	fill_in "user_password", with: 'userpassword'
      		add_data_w_photo
		click_button submit 
	}.not_to change(User, :count)
      end

      it "should not create a user with no photo" do
        expect{ 
		visit new_user_registration_path 
      		user_data
		click_button submit 
	}.not_to change(User, :count)
      end
    end

    def user_data
        user_info
        fill_in 'user_email', :with => 'newuser@example.com'
	user_birth_date
	select('Male', :from => 'user_gender')
        fill_in 'user_password', :with => 'userpassword'
        fill_in "user_password_confirmation", with: 'userpassword'
    end

    def add_data_w_photo
      attach_file('user_pic', Rails.root.join("spec", "fixtures", "photo.jpg"))
    end

    def user_with_photo
      user_data
      add_data_w_photo
    end

    describe "create user" do
      before(:each) do
        visit root_path
        click_link 'Sign up now!'
      end

      it "should create a user" do
        expect { 
	  user_with_photo
	  click_button submit; sleep 2 
	 }.to change(User, :count).by(1)

        page.should have_content 'A message with a confirmation link has been sent to your email address' 
      end	
    end
  end  
end
