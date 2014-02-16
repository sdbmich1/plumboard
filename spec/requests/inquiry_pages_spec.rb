require 'spec_helper'

feature "Inquiries" do
  subject { page }
  let(:user) { FactoryGirl.create(:pixi_user) }
  let(:editor) { FactoryGirl.create :editor, first_name: 'Steve', confirmed_at: Time.now }
  let(:submit) { "Submit" }

  def user_data
    fill_in 'inq_first_name', with: @user.first_name
    fill_in 'inq_last_name', with: @user.last_name
    fill_in 'inq_email', with: @user.email
  end

  def add_inquiry_type
    FactoryGirl.create :inquiry_type
    FactoryGirl.create :inquiry_type, subject: 'Other Questions', code: 'OQ', contact_type: 'inquiry'
  end

  def inquiry_data
    user_data
    fill_in 'inq_comments', with: 'How do I add friends?'
  end

  def set_user
    page.execute_script %Q{ $('#inq_first_name').val("#{@user.first_name}") }
    page.execute_script %Q{ $('#inq_last_name').val("#{@user.last_name}") }
    page.execute_script %Q{ $('#inq_email').val("#{@user.email}") }
  end

  def click_cancel
    page.evaluate_script('window.history.back()')
  end

  def click_cancel_ok
    click_link 'Cancel'
    page.driver.browser.switch_to.alert.accept
  end

  def click_cancel_cancel
    click_link 'Cancel'
    page.driver.browser.switch_to.alert.dismiss
  end

  def click_remove_ok
    click_link 'Remove'
    page.driver.browser.switch_to.alert.accept
  end

  def click_remove_cancel
    click_link 'Remove'
    page.driver.browser.switch_to.alert.dismiss
  end

  describe 'Visit Contact Us Page - non-signed in users' do
    before do
      @user = user
      add_inquiry_type
      visit contact_path
    end

    it { should have_selector('title', text: 'Contact Us') }
    it { should have_content 'Contact Us' }
    it { should have_content 'Pixiboard Relations' }
    it { should have_content 'First Name' }
    it { should have_content 'Last Name' }
    it { should have_content 'Subject' }
    it { should have_selector('.frm-name', visible: false) }
    it { should have_selector('#inq_status', visible: false) }
    it { should have_link('Cancel') }
    it { should have_button('Submit') }

    it "adds an inquiry", js: true do
      expect {
        inquiry_data
        select("Other Questions", :from => "inq_subject")
	click_button submit 
      }.to change(Inquiry, :count).by(1)

      page.should_not have_content("Contact Us")
    end

    it "cancel an inquiry", js: true do
      expect {
        click_cancel_ok
      }.to change(Inquiry, :count).by(0)
      page.should_not have_content("Contact Us")
    end

    it "does not cancel an inquiry", js: true do
      expect {
        click_cancel_cancel
      }.to change(Inquiry, :count).by(0)
      page.should have_content("Contact Us")
    end

    describe "Creates with invalid email information", js: true do
      it "should not create an inquiry with blank email" do
        expect { 
	  inquiry_data
          fill_in 'inq_email', with: ""
          select("Other Questions", :from => "inq_subject")
	}.not_to change(Inquiry, :count)

	page.should have_css("#inq-done-btn[disabled]")
      end

      it "should not create an inquiry with bad email" do
        expect { 
	  inquiry_data
          fill_in 'inq_email', with: "user@x."
          select("Other Questions", :from => "inq_subject")
	  click_button submit 
	}.not_to change(Inquiry, :count)

        page.should have_content 'Email is invalid'
      end
    end
  end

  describe 'Visit Contact Us Page - signed in users' do
    before(:each) do
      login_as(user, :scope => :user, :run_callbacks => false)
      @user = user
      add_inquiry_type
      visit contact_path
    end

    it { should have_selector('title', text: 'Contact Us') }
    it { should have_content 'Contact Us' }
    it { should have_content 'Pixiboard Relations' }
    it { should have_selector('#inq_first_name', visible: false) }
    it { should have_selector('#inq_last_name', visible: false) }
    it { should have_selector('#inq_email', visible: false) }
    it { should have_selector('#inq_status', visible: false) }
    it { should have_content 'Subject' }
    it { should have_content 'From:' }
    it { should have_content @user.name }
    it { should have_link('Cancel') }
    it { should have_button('Submit') }

    it "adds an inquiry", js: true do
      expect {
        # set_user
        select("Other Questions", :from => "inq_subject")
        fill_in 'inq_comments', with: 'How do I add friends?'
	click_button submit 
      }.to change(Inquiry, :count).by(1)

      page.should_not have_content("Contact Us")
    end
  end

  describe 'Visit Contact Us Page - support users' do
    before(:each) do
      login_as(user, :scope => :user, :run_callbacks => false)
      @user = user
      add_inquiry_type
      visit contact_path(source: 'support')
    end

    it { should have_content 'Pixiboard Support' }
    it { should have_selector('title', text: 'Contact Us') }
    it { should have_selector('#inq_first_name', visible: false) }
    it { should have_selector('#inq_last_name', visible: false) }
    it { should have_selector('#inq_email', visible: false) }
    it { should have_selector('#inq_status', visible: false) }
    it { should have_content 'Subject' }
    it { should have_content 'From:' }
    it { should have_content @user.name }
    it { should have_link('Cancel') }
    it { should have_button('Submit') }

    it "adds a support inquiry", js: true do
      expect {
        # set_user
        select("Other Questions", :from => "inq_subject")
        fill_in 'inq_comments', with: 'How do I add friends?'
	click_button submit 
      }.to change(Inquiry, :count).by(1)

      page.should_not have_content("Contact Us")
    end
  end


  describe "Editor views an Inquiry" do 
    before do
      login_as(editor, :scope => :user, :run_callbacks => false)
      @user = user
      @inquiry = @user.inquiries.create FactoryGirl.attributes_for(:inquiry)
      visit inquiries_path 
    end

    it { should have_link("#{@inquiry.id}", href: inquiry_path(@inquiry)) }
    it { should have_selector('title', text: 'Inquiries') }
    it { should have_content "Inquiry #" }
    it { should have_content "User Name" } 
    it { should have_link("#{@inquiry.id}", href: inquiry_path(@inquiry)) }

    it "clicks to open an inquiry" do
      expect { 
        click_on "#{@inquiry.id}"
      }.not_to change(Inquiry, :count)

      page.should have_content 'Inquiry Details'
      page.should have_content "#{@inquiry.id}"
      page.should have_content @inquiry.comments
      page.should have_content @inquiry.user_name
      page.should have_link 'Edit', href: edit_inquiry_path(@inquiry) 
      page.should have_link 'Remove', href: inquiry_path(@inquiry) 
      page.should have_link 'Done', href: root_path 
    end

    it "cancel remove inquiry", js: true do
      expect { 
        click_on "#{@inquiry.id}"
      }.not_to change(Inquiry, :count)

      click_remove_cancel
      page.should have_content "Inquiry Details" 
    end

    it "deletes a inquiry", js: true do
      expect{
        click_on "#{@inquiry.id}"
        click_remove_ok; sleep 3;
      }.to change(Inquiry,:count).by(-1)

      page.should have_content "Inquiries" 
      page.should have_content "No inquiries found." 
    end
  end

  describe "Editor edits a Inquiry" do 
    before do
      login_as(editor, :scope => :user, :run_callbacks => false)
      @user = user
      @inquiry = @user.inquiries.create FactoryGirl.attributes_for(:inquiry)
      visit edit_inquiry_path(@inquiry)
    end

    it "opens edit page" do
      page.should have_selector('title', text: 'Edit Inquiry') 
      page.should have_link 'Cancel'
      page.should have_selector('#inq_status', visible: true) 
      page.should have_button('Submit') 
    end

    it "changes status", js: true do
      expect{
        select('closed', :from => 'inq_status')
        click_button submit; sleep 2
      }.to change(Inquiry,:count).by(0)

      page.should have_content 'Inquiry Details'
      page.should have_content 'Closed'
      page.should have_link 'Edit', href: edit_inquiry_path(@inquiry) 
      page.should have_link 'Remove', href: inquiry_path(@inquiry) 
      page.should have_link 'Done', href: root_path 
    end

    it "cancels inquiry edit", js: true do
      click_cancel_ok; sleep 2
      page.should have_content "Inquiry Details" 
    end

    it "cancels edit of inquiry", js: true do
      click_cancel_cancel
      page.should have_content "From" 
      page.should have_content "Status" 
    end
  end
end

