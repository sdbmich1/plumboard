require 'spec_helper'

feature "Invoices" do
  subject { page }
  let(:user) { FactoryGirl.create(:pixi_user) }

  before(:each) do
    login_as(user, :scope => :user, :run_callbacks => false)
    @user = user
    create_buyers
  end

  def create_buyers
    @buyer1 = FactoryGirl.create(:pixi_user, first_name: 'Bob', last_name: 'Jones', email: 'bjones@pixitest.com') 
    FactoryGirl.create(:pixi_user, first_name: 'Bob', last_name: 'Nelson', email: 'bnelson@pixitest.com') 
    FactoryGirl.create(:pixi_user, first_name: 'Bob', last_name: 'Davis', email: 'bdavis@pixitest.com') 
  end

  def select_buyer
    fill_in "buyer_name", :with => "Bob"
    fill_autocomplete "Bob Jones", "#buyer_name"
  end

  def set_buyer_id
    page.execute_script %Q{ $('#invoice_buyer_id').val("#{@buyer1.id}") }
  end
   
  def select_pixi
    select(@listing.title, :from => 'invoice_pixi_id')
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
    fill_in 'inv_price', with: 200.00
    fill_in 'inv_tax', with: 8.25
    fill_in 'invoice_comment', with: "Thanks for your business."
  end

  def init_data
    @buyer = FactoryGirl.create(:pixi_user, first_name: 'Phil', last_name: 'Hayes') 
    @person = FactoryGirl.create(:pixi_user, first_name: 'Kim', last_name: 'Harris') 
    @listing = FactoryGirl.create(:listing, seller_id: @user.id) 
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
    @invoice2 = @buyer.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing2.pixi_id, buyer_id: @user.id, status: 'paid')  
    @invoice3 = @user.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing3.pixi_id, buyer_id: @person.id)
  end

  def unknown_buyer
    fill_in "buyer_name", :with => "Ed Wilson"
    click_button 'Send'
  end

  def zero_price
    fill_in 'inv_price', with: 0
    click_button 'Send'
    page.should have_content "Price must be greater than 0" 
  end

  describe "Visit Invoices" do
    before do
      visit listings_path 
      click_link 'My Invoices'
    end

    it { should have_content("Invoices") }
    it { should have_selector('title', text: 'Invoices') }
    it { should have_link('Sent', href: invoices_path) }
    it { should have_link('Received', href: received_invoices_path) }
    it { should have_content "No invoices found." }

    describe 'user has no pixis' do
      it { should_not have_link('Create', href: new_invoice_path) }
    end
  end

  describe 'user has pixis w/o bank acct' do
    before do
      FactoryGirl.create(:listing, seller_id: @user.id) 
      visit listings_path 
      click_link 'My Invoices'
    end

    it { should have_link('Create', href: new_bank_account_path(target: 'shared/invoice_form')) }
    it { should_not have_link('Create', href: new_invoice_path) }

    it "displays new invoice link" do
      @user.bank_accounts.create FactoryGirl.attributes_for :bank_account, status: 'active'
      page.should_not have_link 'Create', href: new_bank_account_path
    end
  end

  describe 'user has pixis w bank acct' do
    before do
      FactoryGirl.create(:listing, seller_id: @user.id) 
      @user.bank_accounts.create FactoryGirl.attributes_for :bank_account, status: 'active'
      visit listings_path 
      click_link 'My Invoices'
    end

    it { should_not have_link('Create', href: new_bank_account_path) }
    it { should have_link('Create', href: new_invoice_path) }
  end

  describe "Sent Invoices" do
    before do
      add_invoices
      visit invoices_path 
    end

    it { should have_link("#{@invoice.id}", href: invoice_path(@invoice)) }
    it { should have_content "Status" }
    it { should have_content "Phil Hayes" }
    it { should have_content @listing.title }
  end

  describe "View Unpaid Invoice" do
    before do
      add_invoices
      visit invoices_path 
    end

    it "shows invoice page", js: true do
      page.should have_link("#{@invoice.id}", href: invoice_path(@invoice)) 
    
      click_on "#{@invoice.id}"
      page.should have_content @invoice.buyer.name
      page.should have_content @invoice.listing.title
      page.should have_content "Amount Due" 
      page.should have_link('Edit', href: edit_invoice_path(@invoice)) 
      page.should have_link('Remove', href: invoice_path(@invoice)) 

      click_on 'Edit'
      unknown_buyer
      page.should have_content "Buyer can't be blank" 
    end
  end

  describe "View Paid Invoice" do
    before do
      add_paid_invoice
      visit invoices_path 
    end

    it { should have_link("#{@invoice.id}", href: invoice_path(@invoice)) }

    it "shows invoice page", js: true do
      click_on "#{@invoice.id}"

      page.should have_content "Amount Due" 
      page.should_not have_link('Edit', href: edit_invoice_path(@invoice)) 
      page.should_not have_link('Remove', href: invoice_path(@invoice)) 
    end
  end

  describe "Edit Invoice" do
    before do
      add_invoices
      visit invoices_path 
    end
        
    it { should have_link("#{@invoice.id}", href: invoice_path(@invoice)) }
    it 'changes price', js: true  do
      click_on "#{@invoice.id}"
      page.should have_link('Edit', href: edit_invoice_path(@invoice)) 

      click_on 'Edit'
      zero_price

      fill_in 'inv_price', with: 215.00
      expect { 
	    click_button 'Send'; sleep 3
	}.to change(Invoice, :count).by(0)

      page.should have_content "Status" 
    end
  end

  describe "Remove Invoice" do
    before do
      add_invoices
      visit invoices_path 
    end
        
    it { should have_link("#{@invoice.id}", href: invoice_path(@invoice)) }

    it 'removes invoice', js: true  do
      click_on "#{@invoice.id}"
      page.should have_link('Remove', href: invoice_path(@invoice)) 

      click_remove_cancel
      page.should have_link('Remove', href: invoice_path(@invoice)) 

      click_remove_ok
      page.should_not have_link("#{@invoice.id}", href: invoice_path(@invoice)) 
    end
  end

  describe "Received Invoices w/o Invoices" do
    before do
      visit invoices_path 
    end

    it "has no received invoices", js: true do
      click_link 'Received'
      page.should have_content "No invoices found." 
    end
  end

  describe "Received Invoices w/ Invoices" do
    before do
      add_invoices
      visit invoices_path 
    end

    it "shows received invoices", js: true do
      page.should have_link('Received', href: received_invoices_path) 
      click_link 'Received'
    
      page.should have_content "Status" 
      page.should have_content @user.name
      page.should have_link("#{@invoice.id}", href: invoice_path(@invoice)) 

      click_on "#{@invoice.id}"
      page.should have_button 'Pay'
      page.should have_content "Bookbag" 

      click_on 'Pay'
      page.should have_selector('title', text: 'Pay Invoice') 
      page.should have_content "Review Your Purchase"
      page.should have_content "Bookbag" 
      page.should have_content "Total Due"
    end
  end

  describe "Manage Invoices" do
    before do
      init_data
      visit invoices_path 
      click_link 'Create'
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
          page.should have_content "Pixi can't be blank" 
        end
        
        it 'has pixi' do
	  select_buyer
	  click_button 'Send'
          page.should have_content "can't be blank" 
        end
        
        it 'does not accept unknown buyer' do
	  unknown_buyer
          page.should have_content "Pixi can't be blank" 
        end
        
        it 'must have a buyer' do
	  select_pixi
	  click_button 'Send'
          page.should have_content "Buyer can't be blank" 
        end
        
        it 'does not accept zero price' do
	  select_buyer
	  select_pixi
	  set_buyer_id
	  zero_price
        end
        
        it 'does not accept bad price' do
	  select_buyer
	  select_pixi
	  set_buyer_id
          fill_in 'inv_price', with: "R0"
	  click_button 'Send'
          page.should have_content "Price is not a number" 
        end
        
        it 'should not accept bad sales tax' do
	  select_buyer
	  select_pixi
	  set_buyer_id
          fill_in 'inv_tax', with: "R0"
	  click_button 'Send'
          page.should have_content "is not a number" 
        end
        
        it 'does not accept invalid sales tax' do
	  select_buyer
	  select_pixi
	  set_buyer_id
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
	  expect { 
	    click_button 'Send'; sleep 3
	  }.to change(Invoice, :count).by(1)

	  page.should have_content "Status" 
	  page.should have_content "Bob Jones" 
        end
      end
    end
  end

end
