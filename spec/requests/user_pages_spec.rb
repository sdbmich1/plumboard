require 'spec_helper'

describe "Users", :type => :feature do
  subject { page }
  let(:admin) { create(:admin, user_type_code: 'AD') }
  let(:editor) { create(:editor, user_type_code: 'PX') }
  let(:bus_user) { create(:admin, user_type_code: 'BUS') }
  let(:user) { create(:pixi_user, user_type_code: 'MBR') }

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
      expect(page).to have_link 'All', href: users_path
      expect(page).to have_link 'Pixans', href: users_path(utype: 'PX')
      expect(page).to have_link 'Pixters', href: users_path(utype: 'PT')
      expect(page).to have_link 'Export as CSV file', href: users_path(format: 'csv')
      expect(page).to have_content @member.name
      expect(page).to have_content @user.name
      expect(page).to have_content @pixter.name
      expect(page).to have_content @pixan.name
      expect(page).to have_content 'Enrolled'
      expect(page).to have_content 'Displaying'
    end

    it "should display pixans", js: true do 
      click_link 'Pixans'
      expect(page).to have_link 'All', href: users_path
      expect(page).to have_link 'Pixans', href: users_path(utype: 'PX')
      expect(page).to have_link 'Pixters', href: users_path(utype: 'PT')
      expect(page).to have_content @user.name
      expect(page).not_to have_content @member.name
      expect(page).not_to have_content @pixter.name
      expect(page).to have_content @pixan.name
      expect(page).to have_content 'Enrolled'
    end

    it "should display pixters", js: true do 
      click_link 'Pixters'
      expect(page).to have_link 'All', href: users_path
      expect(page).to have_link 'Pixans', href: users_path(utype: 'PX')
      expect(page).to have_link 'Pixters', href: users_path(utype: 'PT')
      expect(page).not_to have_content @user.name
      expect(page).not_to have_content @member.name
      expect(page).to have_content @pixter.name
      expect(page).not_to have_content @pixan.name
      expect(page).to have_content 'Enrolled'
    end

    it "views user", js: true do
      create_user_types
      expect { 
	visit user_path(@member)
      }.not_to change(User, :count)

      expect(page).to have_content "View User"
      expect(page).to have_content @member.name
      expect(page).to have_content @member.email
      expect(page).to have_content @member.birth_dt
      expect(page).to have_content "Facebook"
      expect(page).to have_content "Address"
      expect(page).not_to have_selector('#follow-btn', visible: true)
      expect(page).to have_link 'Edit', href: edit_user_path(@member) 
      expect(page).to have_link 'Done', href: users_path(utype: @member.user_type_code) 
      expect(page).not_to have_content @user.name

      visit edit_user_path(@member)
      expect {
        select("Subscriber", :from => "ucode")
        click_submit
	}.not_to change(@member.contacts, :count).by(1)
      expect(page).to have_content(@user.first_name)
      expect(page).to have_selector('#ucode', visible: true) 
    end
  end
  
  describe 'Edit individual profile' do
    before do
      user = create(:pixi_user) 
      init_setup user
      visit user_path(@user) 
      click_link 'Profile'
    end

    it "empty first name should not change a profile", js: true do
      expect(page).not_to have_selector('#ucode', visible: true) 
      expect { 
	      fill_in 'user_first_name', with: nil
              click_on 'Save Changes'
	}.not_to change(User, :count)
    end

    it "empty last name should not change a profile", js: true do
      expect { 
	      fill_in 'user_last_name', with: nil
              click_on 'Save Changes'
	}.not_to change(User, :count)
    end

    it "empty email should not change a profile", js: true do
      expect { 
	      fill_in 'user_email', with: nil
              click_on 'Save Changes'
	}.not_to change(User, :count)
    end

    it "changed first name should update a profile", js: true do
      expect { 
	      fill_in 'user_first_name', with: 'Ted'
	      click_save
	      expect(page).to have_content 'Ted'
	}.not_to change(User, :count)
      expect(@user.reload.first_name).to  eq('Ted') 
    end

    it "changed last name should update a profile", js: true do
      expect { 
	      fill_in 'user_last_name', with: 'White'
	      click_save
	}.not_to change(User, :count)
      expect(@user.reload.last_name).to eq('White') 
    end

    it "changed gender should update a profile", js: true do
      expect { 
      	      select('Female', :from => 'user_gender')
	      click_save
	}.not_to change(User, :count)
      expect(@user.reload.gender).to eq('Female') 
    end

    it "empty home_zip should not change a profile", js: true do
      expect { 
	      fill_in 'home_zip', with: nil
              click_on 'Save Changes'
	}.not_to change(User, :count)
    end

    it "invalid home_zip should not change a profile", js: true do
      expect { 
	      fill_in 'home_zip', with: '99999'
              click_on 'Save Changes'
	}.not_to change(User, :count)
    end

    it "changed home zip should update a profile", js: true do
      expect { 
	      fill_in 'home_zip', with: '94111'
	      click_save
	}.not_to change(User, :count)
      expect(@user.reload.home_zip).to eq('94111') 
    end

    it "Changes profile file pic" do
      visit settings_path
      expect{
              attach_file('user_pic', Rails.root.join("spec", "fixtures", "photo0.jpg"))
	      click_save
      }.to change(@user.pictures,:count).by(0)
      expect(page).to have_content("successfully")
    end

    it "changed email should update a profile", js: true do
      expect { 
	      fill_in "user_email", with: "tedwhite@test.com"
	      click_save
	}.not_to change(User, :count)
      expect(@user.reload.unconfirmed_email).to eq("tedwhite@test.com")
    end
  end
  
  describe 'Edit business profile' do
    before do
      create_user_types
      user = create(:pixi_user, business_name: 'PixiBizz', gender: nil, birth_date: nil, user_type_code: 'BUS') 
      init_setup user
      visit user_path(@user) 
    end

    it "changes business name and url", js: true do
      click_link 'Profile'
      check_page_selectors ['#user_url, #user_business_name'], true, false
      # check_page_selectors ['#user_gender'], false
      expect { 
        fill_in 'user_business_name', :with => 'Company A'
	fill_in "user_url", with: "PXB"
	fill_in "user_description", with: "PXB is a great company."
	click_save
	}.not_to change(User, :count)
      expect(@user.reload.url).to eq("PXB")
    end
  end

  describe 'Edit user contact info', js: true do
    let(:contact) { FactoryGirl.build :contact }
    before :each do
      pxuser = create(:pixi_user) 
      create :state
      init_setup pxuser
      visit user_path(@user)
      click_link 'Contact'
    end

    def user_home_phone
      fill_in 'home_phone', with: contact.home_phone
    end

    def user_mobile_phone
      fill_in 'mobile_phone', with: contact.mobile_phone
    end

    def user_work_phone
      fill_in 'work_phone', with: contact.work_phone
    end
     
    def user_address(addr='123 Elm', addr2='Ste 1', city='SF', zip='94103', sflg=true)
      fill_in 'user_contacts_attributes_0_address', with: addr
      fill_in 'user_contacts_attributes_0_address2', with: addr2
      fill_in 'user_contacts_attributes_0_city', with: city
      select("California", :from => "user_contacts_attributes_0_state") if sflg
      fill_in 'user_contacts_attributes_0_zip', with: zip
    end

    it 'shows contact page' do
      expect(page).to have_link("Contact")
      expect(page).to have_content("Home Phone")
      expect(page).to have_content("Mobile Phone")
      expect(page).to have_content("Work Phone")
    end

    it 'should save contact address info' do
      expect(page).to have_link("Contact")
      expect(page).to have_content("Work Phone")
      expect {
        user_address
        click_save
	}.to change(@user.contacts, :count).by(1)
      expect(page).to have_content("successfully")
    end

    it 'should save contact address & home phone info' do
      expect(page).to have_link("Contact")
      expect {
        user_home_phone
        user_address
        click_save
	}.to change(@user.contacts, :count).by(1)
      expect(page).to have_content("successfully")
    end

    it 'should not save home phone' do
      expect(page).to have_link("Contact")
      expect {
        user_home_phone
        click_submit
	}.not_to change(@user.contacts, :count).by(1)
    end

    it 'should not save mobile phone' do
      expect(page).to have_link("Contact")
      expect {
        user_mobile_phone
        click_submit
	}.not_to change(@user.contacts, :count).by(1)
    end

    it 'should not save work phone' do
      expect(page).to have_link("Contact")
      expect {
        user_work_phone
        click_submit
	}.not_to change(@user.contacts, :count).by(1)
    end

    it 'should not save with no address' do
      expect(page).to have_link("Contact")
      expect {
        user_address nil, nil, 'SF', '94103', true
        click_submit
	}.not_to change(@user.contacts, :count).by(1)
    end

    it 'should not save w/o city' do
      expect {
        user_address '123 Elm', nil, nil, '94108'
        click_submit
	}.not_to change(@user.contacts, :count).by(1)
    end

    it 'should not save w/o zip' do
      expect {
        user_address '123 Elm', nil, 'SF', nil
        click_submit
	}.not_to change(@user.contacts, :count).by(1)
    end

    it 'should not save w/o state' do
      expect {
        user_address '123 Elm', nil, 'SF', '94103', false
        click_submit
	}.not_to change(@user.contacts, :count).by(1)
    end
  end
   
  describe 'Change password', js: true do
    before :each do
      init_setup user
      visit user_path(@user)
      click_link 'Password'
    end

    it 'should show change password page' do
      expect(page).to have_button("Change Password")
    end

    it 'should change password' do
      fill_in 'user_password', :with => 'userpassword'
      fill_in "user_password_confirmation", with: 'userpassword'
      click_button 'Change Password'
      expect(page).to have_content("successfully")
    end

    it 'should not accept blank password & confirmation' do
      click_button 'Change Password'
      expect(page).to have_content("Password can't be blank")
    end

    it 'should not accept blank password' do
      fill_in "user_password_confirmation", with: 'userpassword'
      click_button 'Change Password'
      expect(page).to have_content("Password can't be blank")
    end

    it 'should not accept blank password confirmation' do
      fill_in 'user_password', :with => 'userpassword'
      click_button 'Change Password'
      expect(page).to have_content("Password doesn't match confirmation")
    end
  end

  describe 'show user page - admin', show: true do
    before :each do
      member = create(:pixi_user) 
      @mbr, @descr, @url = member.name, member.type_descr, member.user_url
      init_setup admin
      visit user_path(member)  
    end
    it_should_behave_like 'user_show_pages', @mbr, @descr, @url, true, true
  end

  describe 'show user page - editor', show: true do
    before :each do
      member = create(:pixi_user) 
      @mbr, @descr, @url = member.name, member.type_descr, member.user_url
      init_setup editor
      visit user_path(member)  
    end
    it_should_behave_like 'user_show_pages', @mbr, @descr, @url, true, false
  end

  describe 'show user page - user', show: true do
    before :each do
      @mbr, @descr, @url = user.name, user.type_descr, user.user_url
      init_setup user
      visit user_path(user)  
    end
    it_should_behave_like 'user_show_pages', @mbr, @descr, @url, true, false
  end

  describe 'Edit Delivery Preferences' do
    before do
      create :fulfillment_type, code: 'A', description: 'All', status: 'active', hide: 'no'
      create :fulfillment_type, code: 'SHP', description: 'Ship', status: 'active', hide: 'no'
      @user = create :business_user
      init_setup @user
      visit user_path(@user) 
      click_link 'Delivery'
    end

    it "assigns values", js: true do
      expect(page).to have_content 'Delivery Type'
      expect(page).to have_content 'Sales Tax (%)'
      expect(page).to have_content 'Ship Amt'
      select 'All', from: 'user_preferences_attributes_0_fulfillment_type_code'
      fill_in 'inv_tax', with: 9.0
      fill_in 'ship_cost_box', with: 5.0
      click_on 'Save'
      sleep 5
      @user.preferences.first.reload
      expect(@user.preferences.first.fulfillment_type_code).to eq 'A'
      expect(@user.preferences.first.sales_tax).to eq 9.0
      expect(@user.preferences.first.ship_amt).to eq 5.0
    end
  end
end
