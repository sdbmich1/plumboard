require 'spec_helper'

describe "Users", :type => :feature do
  subject { page }
  let(:admin) { FactoryGirl.create(:admin, user_type_code: 'PX') }

  def init_setup usr
    login_as(usr, :scope => :user, :run_callbacks => false)
    @user = usr
  end

  def click_save
    click_on 'Save Changes'; sleep 3
  end

  def click_submit	
    click_on 'Save Changes'
  end

  describe "GET /users" do
    before :each do
      @member =  create(:pixi_user) 
      @pixter = create(:pixi_user, user_type_code: 'PT') 
      @pixan = create(:pixi_user, user_type_code: 'PX') 
      init_setup admin
      visit users_path  
    end

    it "should display users" do 
      page.should have_link 'All', href: users_path
      page.should have_link 'Pixans', href: users_path(utype: 'PX')
      page.should have_link 'Pixters', href: users_path(utype: 'PT')
      page.should have_content @member.name
      page.should have_content @user.name
      page.should have_content @pixter.name
      page.should have_content @pixan.name
      page.should have_content 'Enrolled'
    end

    it "should display pixans", js: true do 
      click_link 'Pixans'
      page.should have_link 'All', href: users_path
      page.should have_link 'Pixans', href: users_path(utype: 'PX')
      page.should have_link 'Pixters', href: users_path(utype: 'PT')
      page.should have_content @user.name
      page.should_not have_content @member.name
      page.should_not have_content @pixter.name
      page.should have_content @pixan.name
      page.should have_content 'Enrolled'
    end

    it "should display pixters", js: true do 
      click_link 'Pixters'
      page.should have_link 'All', href: users_path
      page.should have_link 'Pixans', href: users_path(utype: 'PX')
      page.should have_link 'Pixters', href: users_path(utype: 'PT')
      page.should_not have_content @user.name
      page.should_not have_content @member.name
      page.should have_content @pixter.name
      page.should_not have_content @pixan.name
      page.should have_content 'Enrolled'
    end
  end
  
  describe "Review Users" do 
    before do
      init_setup admin
      visit user_path(user) 
    end

    it "Views a user" do
      page.should have_selector('h2',    text: user.name) 
      page.should have_selector('title', text: 'Settings')
    end
  end

  describe 'Edit profile' do
    before do
      init_setup user
      visit settings_path 
    end

    it "should not add a large pic", js: true do
      expect{
        attach_file('user_pic', Rails.root.join("spec", "fixtures", "photo2.png"))
        click_on 'Save Changes'
      }.not_to change(user.pictures,:count).by(1)

    #  page.should have_content("Pictures photo file size must be in between 0")
    end

    it "empty first name should not change a profile", js: true do
      expect { 
	      fill_in 'user_first_name', with: nil
              click_on 'Save Changes'
	}.not_to change(User, :count)

      page.should have_content("First name can't be blank")
    end

    it "empty last name should not change a profile", js: true do
      expect { 
	      fill_in 'user_last_name', with: nil
              click_on 'Save Changes'
	}.not_to change(User, :count)

      page.should have_content("Last name can't be blank")
    end

    it "empty email should not change a profile", js: true do
      expect { 
	      fill_in 'user_email', with: nil
              click_on 'Save Changes'
	}.not_to change(User, :count)

      page.should have_content("Email can't be blank")
    end

    it "changed first name should update a profile", js: true do
      expect { 
	      fill_in 'user_first_name', with: 'Ted'
	      click_save
	      page.should have_content 'Ted'
	}.not_to change(User, :count)

      user.reload.first_name.should  == 'Ted' 
    end

    it "changed last name should update a profile", js: true do
      expect { 
	      fill_in 'user_last_name', with: 'White'
	      click_save
	}.not_to change(User, :count)

      user.reload.last_name.should == 'White' 
    end

    it "changed gender should update a profile", js: true do
      expect { 
      	      select('Female', :from => 'user_gender')
	      click_save
	}.not_to change(User, :count)

      user.reload.gender.should == 'Female' 
    end

    it "empty home_zip should not change a profile", js: true do
      expect { 
	      fill_in 'home_zip', with: nil
              click_on 'Save Changes'
	}.not_to change(User, :count)

      page.should have_content("Must have a zip")
    end

    it "invalid home_zip should not change a profile", js: true do
      expect { 
	      fill_in 'home_zip', with: '99999'
              click_on 'Save Changes'
	}.not_to change(User, :count)

      page.should have_content("Must have a valid zip")
    end

    it "changed home zip should update a profile", js: true do
      expect { 
	      fill_in 'home_zip', with: '94111'
	      click_save
	}.not_to change(User, :count)

      user.reload.home_zip.should == '94111' 
    end

    it "Changes profile file pic", js: true do
      expect{
              attach_file('user_pic', Rails.root.join("spec", "fixtures", "photo0.jpg"))
	      click_save
      }.to change(user.pictures,:count).by(0)

      page.should have_content("successfully")
    end

    it "changed email should update a profile", js: true do
      expect { 
	      fill_in "user_email", with: "tedwhite@test.com"
	      click_save
	}.not_to change(User, :count)

      user.reload.unconfirmed_email.should == "tedwhite@test.com"
    end
  end

  describe 'Edit user contact info', js: true do
    let(:contact) { FactoryGirl.build :contact }
    before :each do
      FactoryGirl.create :state
      init_setup user
      visit settings_path
      click_link 'Contact'
    end

    def user_home_phone
      fill_in 'user_contacts_attributes_0_home_phone', with: contact.home_phone
    end

    def user_mobile_phone
      fill_in 'user_contacts_attributes_0_mobile_phone', with: contact.mobile_phone
    end

    def user_work_phone
      fill_in 'user_contacts_attributes_0_work_phone', with: contact.work_phone
    end
     
    def user_address(addr='123 Elm', addr2='Ste 1', city='SF', zip='94103', sflg=true)
      fill_in 'user_contacts_attributes_0_address', with: addr
      fill_in 'user_contacts_attributes_0_address2', with: addr2
      fill_in 'user_contacts_attributes_0_city', with: city
      select("California", :from => "user_contacts_attributes_0_state") if sflg
      fill_in 'user_contacts_attributes_0_zip', with: zip
    end

    it 'should show contact page' do
      page.should have_content("Home Phone")
    end

    it 'should save contact address info' do
      expect {
        user_address
        click_save
	}.to change(user.contacts, :count).by(1)
      page.should have_content("successfully")
    end

    it 'should save contact address & home phone info' do
      expect {
        user_home_phone
        user_address
        click_save
	}.to change(user.contacts, :count).by(1)
      page.should have_content("successfully")
    end

    it 'should not save home phone' do
      expect {
        user_home_phone
        click_submit
	}.not_to change(user.contacts, :count).by(1)
    end

    it 'should not save mobile phone' do
      expect {
        user_mobile_phone
        click_submit
	}.not_to change(user.contacts, :count).by(1)
    end

    it 'should not save work phone' do
      expect {
        user_work_phone
        click_submit
	}.not_to change(user.contacts, :count).by(1)
    end

    it 'should not save with no address' do
      expect {
        user_address nil, nil, 'SF', '94103', true
        click_submit
	}.not_to change(user.contacts, :count).by(1)
    end

    it 'should not save w/o city' do
      expect {
        user_address '123 Elm', nil, nil, '94108'
        click_submit
	}.not_to change(user.contacts, :count).by(1)
    end

    it 'should not save w/o zip' do
      expect {
        user_address '123 Elm', nil, 'SF', nil
        click_submit
	}.not_to change(user.contacts, :count).by(1)
    end

    it 'should not save w/o state' do
      expect {
        user_address '123 Elm', nil, 'SF', '94103', false
        click_submit
	}.not_to change(user.contacts, :count).by(1)
    end
  end
   
  describe 'Change password', js: true do
    before :each do
      init_setup user
      visit settings_path
      click_link 'Password'
    end

    it 'should show change password page' do
      page.should have_button("Change Password")
    end

    it 'should change password' do
      fill_in 'user_password', :with => 'userpassword'
      fill_in "user_password_confirmation", with: 'userpassword'
      click_button 'Change Password'
      page.should have_content("successfully")
    end

    it 'should not accept blank password & confirmation' do
      click_button 'Change Password'
      page.should have_content("Password can't be blank")
    end

    it 'should not accept blank password' do
      fill_in "user_password_confirmation", with: 'userpassword'
      click_button 'Change Password'
      page.should have_content("Password can't be blank")
    end

    it 'should not accept blank password confirmation' do
      fill_in 'user_password', :with => 'userpassword'
      click_button 'Change Password'
      page.should have_content("Password doesn't match confirmation")
    end
  end
end
