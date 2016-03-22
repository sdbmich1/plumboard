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

  def add_inquiry_type icode='OQ', ctype='inquiry'
    @support_type = FactoryGirl.create :inquiry_type
    @iq_type = FactoryGirl.create :inquiry_type, subject: 'Other Questions', code: icode, contact_type: ctype
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

    it "shows content" do
      expect(page).to have_selector('title', text: 'Contact Us')
      expect(page).to have_content 'Contact Us'
      expect(page).to have_content 'Pixiboard Relations'
      expect(page).to have_content 'First Name'
      expect(page).to have_content 'Last Name'
      expect(page).to have_content 'Subject'
      expect(page).to have_selector('.frm-name', visible: false)
      expect(page).to have_selector('#inq_status', visible: false)
      expect(page).to have_link('Cancel')
      expect(page).to have_button('Submit')
    end

    it "adds an inquiry", js: true do
      expect {
        inquiry_data
        select("Other Questions", :from => "inq_subject")
	click_button submit 
      }.to change(Inquiry, :count).by(1)

      expect(page).not_to have_content("Contact Us")
    end

    it "cancel an inquiry", js: true do
      expect {
        click_cancel_ok
      }.to change(Inquiry, :count).by(0)
      expect(page).not_to have_content("Contact Us")
    end

    it "does not cancel an inquiry", js: true do
      expect {
        click_cancel_cancel
      }.to change(Inquiry, :count).by(0)
      expect(page).to have_content("Contact Us")
    end

    describe "Creates with invalid email information", js: true do
      it "should not create an inquiry with blank email" do
        expect { 
	  inquiry_data
          fill_in 'inq_email', with: ""
          select("Other Questions", :from => "inq_subject")
	}.not_to change(Inquiry, :count)

	expect(page).to have_css("#inq-done-btn[disabled]")
      end

      it "should not create an inquiry with bad email" do
        expect { 
	  inquiry_data
          fill_in 'inq_email', with: "user@x."
          select("Other Questions", :from => "inq_subject")
	  click_button submit 
	}.not_to change(Inquiry, :count)

        expect(page).to have_content 'Email is invalid'
      end
    end
  end

  describe 'Visit Contact Us Page - signed in users' do
    before(:each) do
      init_setup user
      add_inquiry_type
      visit contact_path
    end

    it "shows content" do
      expect(page).to have_selector('title', text: 'Contact Us')
      expect(page).to have_content 'Contact Us'
      expect(page).to have_content 'Pixiboard Relations'
      expect(page).to have_selector('#inq_first_name', visible: false)
      expect(page).to have_selector('#inq_last_name', visible: false)
      expect(page).to have_selector('#inq_email', visible: false)
      expect(page).to have_selector('#inq_status', visible: false)
      expect(page).to have_content 'Subject'
      expect(page).to have_content 'From:'
      expect(page).to have_content @user.name
      expect(page).to have_link('Cancel')
      expect(page).to have_button('Submit')
    end

    it "adds an inquiry", js: true do
      expect {
        # set_user
        select("Other Questions", :from => "inq_subject")
        fill_in 'inq_comments', with: 'How do I add friends?'
	click_button submit 
      }.to change(Inquiry, :count).by(1)

      expect(page).not_to have_content("Contact Us")
    end
  end

  describe 'Visit Contact Us Page - support users' do
    before(:each) do
      init_setup user
      add_inquiry_type 'OT', 'support'
      visit contact_path(source: 'support')
    end

    it "shows content" do
      expect(page).to have_content 'Pixiboard Support'
      expect(page).to have_selector('title', text: 'Contact Us')
      expect(page).to have_selector('#inq_first_name', visible: false)
      expect(page).to have_selector('#inq_last_name', visible: false)
      expect(page).to have_selector('#inq_email', visible: false)
      expect(page).to have_selector('#inq_status', visible: false)
      expect(page).to have_content 'Subject'
      expect(page).to have_content 'From:'
      expect(page).to have_content @user.name
      expect(page).to have_link('Cancel')
      expect(page).to have_button('Submit')
    end

    it "adds a support inquiry", js: true do
      expect {
        # set_user
        select("Other Questions", :from => "inq_subject")
        fill_in 'inq_comments', with: 'How do I add friends?'
	click_button submit 
      }.to change(Inquiry, :count).by(1)

      expect(page).not_to have_content("Contact Us")
    end
  end


  describe "Editor views an Inquiry" do 
    before do
      add_inquiry_type
      init_setup editor
      @site = create :site
      @inquiry = @user.inquiries.create FactoryGirl.attributes_for(:inquiry, code: 'OQ')
      @support = @user.inquiries.create FactoryGirl.attributes_for(:inquiry, code: 'WS')
      @closed = @user.inquiries.create FactoryGirl.attributes_for(:inquiry, status: 'closed')
      visit inquiries_path(ctype: 'inquiry') 
    end

    it "shows content" do
      expect(page).not_to have_content('No inquiries found')
      expect(page).to have_link 'General', href: inquiries_path(ctype: 'inquiry')
      expect(page).to have_link 'Support', href: inquiries_path(ctype: 'support')
      expect(page).to have_link 'Closed', href: closed_inquiries_path
      expect(page).to have_link("#{@inquiry.id}", href: inquiry_path(@inquiry))
      expect(page).to have_selector('title', text: 'Inquiries')
      expect(page).to have_content "Inquiry #"
      expect(page).to have_content "User Name" 
      expect(page).not_to have_link("#{@support.id}", href: inquiry_path(@support))
      expect(page).not_to have_link("#{@closed.id}", href: inquiry_path(@closed))
    end

    it "displays support inquiries", js: true do
      page.find('#support-inq').click
      expect(page).not_to have_content 'No inquiries found.'
      expect(page).to have_link("#{@support.id}", href: inquiry_path(@support)) 
      expect(page).not_to have_link("#{@closed.id}", href: inquiry_path(@closed)) 
      expect(page).not_to have_link("#{@inquiry.id}", href: inquiry_path(@inquiry)) 
    end

    it "displays closed inquiries", js: true do
      page.find('#closed-inq').click
      expect(page).not_to have_content 'No inquiries found.'
      expect(page).to have_link("#{@closed.id}", href: inquiry_path(@closed)) 
      expect(page).not_to have_link("#{@support.id}", href: inquiry_path(@support)) 
      expect(page).not_to have_link("#{@inquiry.id}", href: inquiry_path(@inquiry)) 
    end

    it "clicks to open an inquiry" do
      @loc = @site.id
      create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id ) 
      stub_const("MIN_PIXI_COUNT", 0)
      expect(MIN_PIXI_COUNT).to eq(0)
      expect { 
        click_on "#{@inquiry.id}"
      }.not_to change(Inquiry, :count)

      expect(page).to have_content 'Inquiry Details'
      expect(page).to have_content "#{@inquiry.id}"
      expect(page).to have_content @inquiry.comments
      expect(page).to have_content @inquiry.user_name
      expect(page).to have_link 'Edit', href: edit_inquiry_path(@inquiry, source: 'inquiry') 
      expect(page).to have_link 'Remove', href: @inquiry 
      expect(page).to have_selector('#done-inquiry-btn', href: inquiries_path(ctype: 'inquiry'))
    end

    it "clicks to open an inquiry w/ local listing home" do
      @loc = @site.id
      create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id ) 
      stub_const("MIN_PIXI_COUNT", 500)
      expect(MIN_PIXI_COUNT).to eq(500)
      expect { 
        click_on "#{@inquiry.id}"
      }.not_to change(Inquiry, :count)

      expect(page).to have_content 'Inquiry Details'
      expect(page).to have_content "#{@inquiry.id}"
      expect(page).to have_content @inquiry.comments
      expect(page).to have_content @inquiry.user_name
      expect(page).to have_link 'Edit', href: edit_inquiry_path(@inquiry, source: 'inquiry') 
      expect(page).to have_link 'Remove', href: inquiry_path(@inquiry)
      expect(page).to have_selector('#done-inquiry-btn', href: inquiries_path(ctype: 'inquiry'))
    end

    it "cancel remove inquiry", js: true do
      expect { 
        click_on "#{@inquiry.id}"
      }.not_to change(Inquiry, :count)

      click_remove_cancel
      expect(page).to have_content "Inquiry Details" 
    end

    it "deletes a inquiry", js: true do
      expect{
        click_on "#{@inquiry.id}"
        click_remove_ok; sleep 3;
      }.to change(Inquiry,:count).by(-1)

      expect(page).to have_content "Inquiries" 
      expect(page).to have_content "No inquiries found." 
    end

    it 'shows a closed inquiry', js: true do
      page.find('#closed-inq').click
      expect { 
        click_on "#{@closed.id}"
      }.not_to change(Inquiry, :count)
      expect(page).not_to have_link 'Edit', href: edit_inquiry_path(@inquiry, source: 'inquiry') 
      expect(page).to have_link('Done', href: inquiries_path(ctype: 'inquiry'))
      expect(page).to have_link('Remove')
    end
  end

  describe "Editor edits a Inquiry" do 
    before do
      init_setup editor
      create :inquiry_type
      @inquiry = @user.inquiries.create FactoryGirl.attributes_for(:inquiry)
      visit edit_inquiry_path(@inquiry, source: 'support')
    end

    it "opens edit page" do
      expect(page).to have_content 'Pixiboard Support'
      expect(page).to have_content @inquiry.user_name
      expect(page).not_to have_content @user.name
      expect(page).to have_selector('title', text: 'Edit Inquiry') 
      expect(page).to have_link 'Cancel'
      expect(page).to have_selector('#inq_status', visible: true) 
      expect(page).to have_button('Submit') 
    end

    it "changes status", js: true do
      expect{
        select('closed', :from => 'inq_status')
        click_button submit; sleep 2
      }.to change(Inquiry,:count).by(0)

      expect(page).to have_content 'Inquiry Details'
      expect(page).to have_content 'Closed'
      expect(page).to have_link 'Edit', href: edit_inquiry_path(@inquiry, source: 'support') 
      expect(page).to have_link 'Remove', href: inquiry_path(@inquiry) 
      expect(page).to have_link 'Done', href: inquiries_path(ctype: 'inquiry') 
    end

    it "cancels inquiry edit", js: true do
      click_cancel_ok; sleep 2
      expect(page).to have_content "Inquiry Details" 
    end

    it "cancels edit of inquiry", js: true do
      click_cancel_cancel
      expect(page).to have_content "From" 
      expect(page).to have_content "Status" 
    end
  end
end

