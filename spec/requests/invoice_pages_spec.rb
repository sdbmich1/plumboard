require 'spec_helper'

feature "Invoices" do
  subject { page }
  let(:user) { FactoryGirl.create(:pixi_user) }

  before(:each) do
    create_buyers
  end

  def init_setup usr
    login_as(usr, :scope => :user, :run_callbacks => false)
    @user = usr
  end

  def create_buyers
    @buyer = FactoryGirl.create(:pixi_user, first_name: 'Phil', last_name: 'Hayes') 
    @buyer1 = FactoryGirl.create(:pixi_user, first_name: 'Bob', last_name: 'Jones', email: 'bjones@pixitest.com') 
    FactoryGirl.create(:pixi_user, first_name: 'Bob', last_name: 'Nelson', email: 'bnelson@pixitest.com') 
    FactoryGirl.create(:pixi_user, first_name: 'Bob', last_name: 'Davis', email: 'bdavis@pixitest.com') 
  end

  def select_buyer
    # fill_in "buyer_name", :with => "Bob"
    fill_autocomplete "buyer_name", with: "Bob Jones"
  end

  def set_buyer_id
    page.execute_script %Q{ $('#invoice_buyer_id').val("#{@buyer1.id}") }
  end
   
  def select_buyer_name
    select(@buyer.name, :from => 'tmp_buyer_id')
  end
   
  def select_pixi
    select(@listing.title, :from => 'invoice_pixi_id')
  end

  def calc_fee
    (@pxp_listing.price * PXB_TXN_PERCENT).round(2)
  end
   
  def select_pixi_post
    select(@pxp_listing.title, :from => 'invoice_pixi_id')
  end

  def edit_invoice
    click_on "#{@invoice.id}"; sleep 2;
    click_on 'Edit'
  end

  def click_remove_ok
    click_link 'Remove'
    page.driver.browser.switch_to.alert.accept
  end
	                  
  def click_remove_cancel
    click_link 'Remove'
    page.driver.browser.switch_to.alert.dismiss
  end

  def add_data
    select_buyer
    select("2", :from => "inv_qty")
    select_pixi
    set_buyer_id
    # fill_in 'inv_price', with: 200.00
    fill_in 'inv_tax', with: 8.25
    # fill_in 'invoice_comment', with: "Thanks for your business."
  end

  def init_data
    @person = FactoryGirl.create(:pixi_user, first_name: 'Kim', last_name: 'Harris') 
    @listing = FactoryGirl.create(:listing, seller_id: @user.id) 
    @pxp_listing = FactoryGirl.create(:listing, seller_id: @user.id, pixan_id: @person.id) 
    @user.bank_accounts.create FactoryGirl.attributes_for :bank_account, status: 'active'
  end

  def add_paid_invoice
    init_data
    @invoice = @user.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @buyer.id, status: 'paid')  
  end

  def add_invoices
    init_data
    @invoice = @user.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @buyer.id)
    @listing2 = FactoryGirl.create(:listing, title: 'Leather Bookbag', seller_id: @buyer.id) 
    @listing3 = FactoryGirl.create(:listing, title: 'Xbox 360', seller_id: @person.id) 
    @listing4 = FactoryGirl.create(:listing, title: 'Trek Bike', seller_id: @buyer.id) 
    @invoice2 = @buyer.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing2.pixi_id, buyer_id: @user.id, status: 'paid')  
    @invoice3 = @user.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing3.pixi_id, buyer_id: @person.id)
    sleep 2
    @invoice4 = @buyer.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing4.pixi_id, buyer_id: @user.id)
  end

  def unknown_buyer
    fill_in "buyer_name", :with => "Ed Wilson"
    click_button 'Send'
  end

  def zero_price
    fill_in 'inv_price', with: 0
    click_button 'Send'
    page.should have_content "Amount must be greater than 0" 
  end

  describe "Check menu invoice link" do
    before do
      px_user = create :pixi_user
      init_setup px_user
      visit root_path 
    end

    describe 'user has no pixis' do
      it { should_not have_link('Bill', href: new_invoice_path) }
    end
  end

  describe 'user has pixis w/o bank acct' do
    before do
      px_user = create :pixi_user
      init_setup px_user
      FactoryGirl.create(:listing, seller_id: @user.id) 
      visit root_path 
    end

    it 'shows content' do
      page.should have_link('Bill', href: new_bank_account_path(target: 'shared/invoice_form'))
      page.should_not have_link('Bill', href: new_invoice_path)
    end
  end

  describe 'user has pixis w bank acct' do
    before do
      px_user = create :pixi_user
      init_setup px_user
      FactoryGirl.create(:listing, seller_id: @user.id) 
      @user.bank_accounts.create FactoryGirl.attributes_for :bank_account, status: 'active'
      visit root_path 
    end

    it 'shows content' do
      page.should_not have_link('Bill', href: new_bank_account_path(target: 'shared/invoice_form'))
      page.should have_link('Bill', href: new_invoice_path)
    end
  end

  describe "Seller checks invoices" do
    before do
      px_user = create :pixi_user
      init_setup px_user
      visit root_path 
      click_link 'My Invoices'
    end

    it 'shows content' do
      page.should have_content("Invoices")
      page.should have_selector('title', text: 'Invoices')
      page.should have_link('Sent', href: sent_invoices_path)
      page.should have_link('Received', href: received_invoices_path)
      page.should have_content "No invoices found."
    end
  end

  describe "Sent Invoices" do
    before do
      px_user = create :pixi_user
      init_setup px_user
      add_invoices
      visit sent_invoices_path 
    end

    it 'shows content' do
      page.should have_link("#{@invoice.id}", href: invoice_path(@invoice))
      page.should have_content "Status"
      page.should have_content "Phil Hayes"
      page.should have_content @listing.title
    end

    it "shows invoice page" do
      page.should have_link("#{@invoice.id}", href: invoice_path(@invoice)) 
      visit invoice_path(@invoice)
      page.should have_content @invoice.buyer_name
      page.should have_content @invoice.pixi_title
      page.should have_content "Amount Due" 
      page.should have_content @invoice.amount
      page.should have_content "Less Convenience Fee"
      page.should have_content "#{@invoice.get_fee(true)}"
      page.should have_content "Amount You Receive"
      page.should have_content "#{@invoice.amount - @invoice.get_fee(true)}"
      page.should have_link('Edit', href: edit_invoice_path(@invoice)) 
      page.should have_link('Remove', href: invoice_path(@invoice)) 
    end
  end

  describe "View Paid Invoice" do
    before do
      px_user = create :pixi_user
      init_setup px_user
      add_paid_invoice
      visit sent_invoices_path 
    end

    it "shows invoice page" do
      page.should have_link("#{@invoice.id}", href: invoice_path(@invoice)) 
      visit invoice_path(@invoice)
      page.should have_content "Amount Due" 
      page.should_not have_link('Edit', href: edit_invoice_path(@invoice)) 
      page.should_not have_link('Remove', href: invoice_path(@invoice)) 
    end
  end

  describe "Edit Invoice" do
    before do
      px_user = create :pixi_user
      init_setup px_user
      add_invoices
      visit sent_invoices_path 
    end
        
    it 'changes price', js: true  do
      page.should have_link("#{@invoice.id}", href: invoice_path(@invoice)) 
      visit invoice_path(@invoice)
      page.should have_link('Edit', href: edit_invoice_path(@invoice)) 

      click_on 'Edit'
      zero_price
      fill_in 'inv_price', with: 215.00
      expect { 
	    click_button 'Send'; sleep 3
	}.to change(Invoice, :count).by(0)
      page.should have_content "Status" 
    end
        
    it 'removes invoice', js: true  do
      page.should have_link("#{@invoice.id}", href: invoice_path(@invoice)) 
      visit invoice_path(@invoice)
      page.should have_link('Remove', href: invoice_path(@invoice)) 
      click_remove_cancel
      page.should have_link('Remove', href: invoice_path(@invoice)) 

      click_remove_ok
      page.should_not have_link("#{@invoice.id}", href: invoice_path(@invoice)) 
    end
  end

  describe "Received Invoices w/o Invoices" do
    before do
      px_user = create :pixi_user
      init_setup px_user
      visit sent_invoices_path 
    end

    it "has no received invoices", js: true do
      click_link 'Received'
      page.should have_content "No invoices found." 
    end
  end

  describe "Received Invoices w/ Invoices" do
    before do
      px_user = create :pixi_user
      init_setup px_user
      add_invoices
      visit sent_invoices_path 
    end

    it "shows paid received invoices", js: true do
      page.should have_link('Received', href: received_invoices_path) 
      click_link 'Received'
    
      page.should have_content "Status" 
      page.should have_content @buyer.name
      page.should have_link("#{@invoice2.id}", href: invoice_path(@invoice2)) 

      visit invoice_path(@invoice2)
      page.should have_content "Bookbag" 
      page.should_not have_content "Less Convenience Fee"
      page.should have_content "Convenience Fee"
      page.should_not have_content "#{@invoice.get_fee(true)}"
      page.should_not have_content "Amount You Receive"
      page.should have_content "#{@invoice.amount + @invoice.get_fee}"
      page.should_not have_selector('#pay-btn') 
    end

    it "shows unpaid received invoices", js: true do
      page.should have_link('Received', href: received_invoices_path) 
      click_link 'Received'
      page.should have_link("#{@invoice4.id}", href: invoice_path(@invoice4)) 

      visit invoice_path(@invoice4)
      page.should have_content "Trek Bike" 
      page.should have_selector('#pay-btn', visible: true) 

      page.find('#pay-btn').click
      page.should have_content "Trek Bike" 
      page.should have_content "Total Due"
    end
  end

  describe "Manage Invoices" do
    before do
      px_user = create :pixi_user
      init_setup px_user
      init_data
      visit sent_invoices_path 
      click_link 'Bill'
    end

    it "displays invoice content", js: true do
      page.should have_content "From:" 
      page.should have_content @user.name 
      page.should have_content "Bill To:" 
      page.should have_content "Amount Due" 
    end 

    describe "Create Invoices" do

      describe 'invalid invoices', js: true do
        it 'does not submit empty form' do
	  click_button 'Send'
          page.should have_content "can't be blank" 
        end
        
        it 'has pixi' do
	  select_buyer
	  click_button 'Send'
          page.should have_content "can't be blank" 
        end
        
        it 'does not accept unknown buyer' do
	  unknown_buyer
          page.should have_content "can't be blank" 
        end
        
        it 'must have a buyer' do
	  select_pixi
	  click_button 'Send'
          page.should have_content "Buyer can't be blank" 
        end
        
        it 'should not accept bad sales tax' do
	  select_buyer
	  select_pixi
	  set_buyer_id
          fill_in 'inv_price', with: "40"
          fill_in 'inv_tax', with: "R0"
	  click_button 'Send'
          page.should have_content "is not a number" 
        end
        
        it 'does not accept invalid sales tax' do
	  select_buyer
	  select_pixi
	  set_buyer_id
          fill_in 'inv_price', with: "40"
          fill_in 'inv_tax', with: 5000
	  click_button 'Send'
          page.should have_content "Sales tax must be less than or equal to 100" 
        end
      end

      describe 'valid invoices', js: true do
        it 'accepts invoice with sales tax' do
	  add_data
	  expect { 
	    click_button 'Send'; sleep 3
	  }.to change(Invoice, :count).by(1)

	  page.should have_content "Status" 
	  page.should have_content "Bob Jones" 
        end
        
        it 'accepts invoice w/o sales tax' do
	  select_buyer
	  select_pixi
	  set_buyer_id
          fill_in 'inv_price', with: "40"
	  expect { 
	    click_button 'Send'; sleep 3
	  }.to change(Invoice, :count).by(1)

	  page.should have_content "Status" 
	  page.should have_content "Bob Jones" 
        end

        it 'accepts invoice with pixi post' do
	  select_pixi_post
	  select_buyer
	  set_buyer_id
	  expect { 
	    click_button 'Send'; sleep 3
	  }.to change(Invoice, :count).by(1)

	  page.should have_content "Status" 
	  page.should have_content "Bob Jones" 
          page.should have_content "#{@pxp_listing.price}"
        end
      end
    end
  end

  describe "Create More Invoices" do
    before do
      init_setup user
      init_data
      @buyer.pixi_wants.create FactoryGirl.attributes_for :pixi_want, pixi_id: @listing.pixi_id
      visit new_invoice_path 
    end
        
    it 'invoice w/ wanted buyers', js: true do
      select_pixi
      page.should have_selector "#buyer_name"
      page.execute_script("$('#buyer_name').toggle();")
      page.should have_selector "#tmp_buyer_id"
      page.execute_script("$('#tmp_buyer_id').toggle();")
      select_buyer_name
      fill_in 'inv_price', with: "40"
      expect { 
	    click_button 'Send'; sleep 3
      }.to change(Invoice, :count).by(1)

      page.should have_content "Status" 
      page.should have_content @buyer.name
    end
  end

end
