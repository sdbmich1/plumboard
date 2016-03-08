require 'spec_helper'

feature "UserRegistrations" do
  subject { page }

  describe 'allows a user to register' do
    let(:submit) { "Register" } 

    describe "with invalid information" do
      before :each do  
        create_user_types
        visit new_user_registration_path 
	page.find('#signup-email-btn').click
      end

      it 'shows content' do
        expect(page).to have_content 'Already have an account?'
        expect(page).to have_link 'Sign In', href: new_user_session_path
        expect(page).to have_link "Pixiboard's Terms of Service", href: terms_path
        expect(page).to have_link 'Privacy Policy', href: privacy_path
      end

      it "should not create a empty user" do
        expect{ 
          fill_in "user_first_name", with: ''
	  click_button submit 
	}.not_to change(User, :count)
        expect(page).to have_content "Create Your Account"
      end

      it "should not create a incomplete user" do
        expect{ 
		reg_user_info
		click_button submit 
	}.not_to change(User, :count)
        expect(page).to have_content "Create Your Account"
      end

      it "should not create user w/o email" do
        expect{ 
		reg_user_info
		reg_user_birth_date
		select('Male', :from => 'user_gender')
		click_button submit 
	}.not_to change(User, :count)
        expect(page).to have_content "Create Your Account"
      end

      it "should not create user w/o gender" do
        expect{ 
		reg_user_info
		reg_user_birth_date
        	fill_in 'user_email', :with => 'newuser@example.com'
		reg_user_pwd
      		add_data_w_photo
		click_button submit 
	}.not_to change(User, :count)
        expect(page).to have_content "Create Your Account"
      end

      it "should not create user w/o birthdate" do
        expect{ 
		reg_user_info
		select('Male', :from => 'user_gender')
        	fill_in 'user_email', :with => 'newuser@example.com'
		reg_user_pwd
      		add_data_w_photo
		click_button submit 
	}.not_to change(User, :count)
        expect(page).to have_content "Create Your Account"
      end

      it "should not create user w/o zip" do
        expect{ 
		reg_user_info
		reg_user_birth_date
		select('Male', :from => 'user_gender')
        	fill_in 'user_email', :with => 'newuser@example.com'
		reg_user_pwd
      		add_data_w_photo
		click_button submit 
	}.not_to change(User, :count)
        expect(page).to have_content "Create Your Account"
      end

      it "should not create user w/o valid zip" do
        expect{ 
		reg_user_info
		reg_user_birth_date
		select('Male', :from => 'user_gender')
        	fill_in 'user_email', :with => 'newuser@example.com'
		reg_user_pwd
                fill_in 'home_zip', :with => '99999'
      		add_data_w_photo
		click_button submit 
	}.not_to change(User, :count)
        expect(page).to have_content "Create Your Account"
      end

      it "should not create user w/o password" do
        expect{ 
		reg_user_info
		reg_user_birth_date
		select('Male', :from => 'user_gender')
        	fill_in 'user_email', :with => 'newuser@example.com'
        #	fill_in "user_password_confirmation", with: 'userpassword'
      		add_data_w_photo
		click_button submit 
	}.not_to change(User, :count)
        expect(page).to have_content "Create Your Account"
      end

      it "should not create user w/o password confirmation" do
        expect{ 
		reg_user_info
		reg_user_birth_date
		select('Male', :from => 'user_gender')
        	fill_in 'user_email', :with => 'newuser@example.com'
        	fill_in "user_password", with: 'userpassword'
      		add_data_w_photo
		click_button submit 
	}.not_to change(User, :count)
        expect(page).to have_content "Create Your Account"
      end

      it "should not create a user with no photo" do
        expect{ 
      		reg_user_data
		click_button submit 
	}.not_to change(User, :count)
        expect(page).to have_content "Create Your Account"
      end

      it "should not create a business user with name" do
        expect{ 
      		reg_user_data false
		reg_user_birth_date
      		add_data_w_photo
        	fill_in "user_business_name", with: ''
		click_button submit 
	}.not_to change(User, :count)
        expect(page).to have_content "Create Your Account"
      end
    end
    
    describe 'create user from registration page', process: true do
      before :each do
        create_user_types
        visit new_user_registration_path 
	page.find('#signup-email-btn').click
      end 

      it "should create a user - local pix" do
        register
      end	

      it "should create a user" do
        register "NO"
      end	
    end

    describe "create user from modal", process: true do
      before(:each) do
        create_user_types
        visit root_path
        click_link 'Signup'; sleep 2
	page.find('#signup-email-btn').click
      end

      it "should create a user - local pix" do
        check_page_selectors ['#pwd, #register-btn'], true, false
        register 'YES', 1
      end	

      it "should create a user" do
        check_page_selectors ['#pwd, #register-btn'], true, false
        register "NO", 1
      end

      it "should create a business user" do
        register "NO", 1, false
      end	
    end
  end  
end
