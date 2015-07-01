require 'spec_helper'

feature "Invoices" do
  subject { page }
  let(:user) { FactoryGirl.create(:pixi_user) }

  before(:each) do
    create_buyers
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
   
  def select_pixi item, fld='pixi_id1'
    select(item.title, :from => fld)
  end

  def calc_fee
    (@pxp_listing.price * PXB_TXN_PERCENT).round(2)
  end

  def edit_invoice
    click_on "#{@invoice.id}"; sleep 2;
    click_on 'Edit'
  end

  def add_data fld='inv_qty1'
    select_buyer
    select("2", :from => fld)
    select_pixi @listing
    set_buyer_id
    # fill_in 'inv_price', with: 200.00
    fill_in 'inv_tax', with: 8.25
    # fill_in 'invoice_comment', with: "Thanks for your business."
  end

  def init_data pxpFlg=true
    @person = create(:pixi_user, first_name: 'Kim', last_name: 'Harris') 
    @listing = create(:listing, seller_id: @user.id)
    @pixi = create(:listing, title: 'Macbook Pro', seller_id: @user.id)
    @free = create(:listing, title: 'Free Item', seller_id: @user.id, price: nil)
    if pxpFlg
      @pxp_listing = create(:listing, seller_id: @user.id, pixan_id: @person.id)
    end
    @user.bank_accounts.create FactoryGirl.attributes_for :bank_account, status: 'active'
    @user.reload
  end

  def add_paid_invoice pxpFlg=true
    init_data pxpFlg
    @invoice = @user.invoices.build FactoryGirl.attributes_for(:invoice, buyer_id: @buyer.id, status: 'paid')
    @details = @invoice.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: @listing.pixi_id 
    @invoice.save!
    @listing.status = 'sold'; @listing.save(validate: false)
  end

  def add_invoices
    init_data
    @invoice = @user.invoices.build FactoryGirl.attributes_for(:invoice, buyer_id: @buyer.id)
    @details = @invoice.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: @listing.pixi_id 
    @invoice.save!
    @listing2 = create(:listing, title: 'Leather Bookbag', seller_id: @buyer.id) 
    @listing3 = create(:listing, title: 'Xbox 360', seller_id: @person.id) 
    @listing4 = create(:listing, title: 'Trek Bike', seller_id: @buyer.id) 
    @invoice2 = @buyer.invoices.build attributes_for(:invoice, buyer_id: @user.id, status: 'paid')
    @details2 = @invoice2.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: @listing2.pixi_id 
    @invoice2.save!
    sleep 2
    @invoice3 = @user.invoices.build FactoryGirl.attributes_for(:invoice, buyer_id: @person.id, status: 'paid')
    @details3 = @invoice3.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: @listing3.pixi_id 
    @invoice3.save!
    sleep 2
    @invoice4 = @buyer.invoices.build FactoryGirl.attributes_for(:invoice, buyer_id: @user.id)
    @details4 = @invoice4.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: @listing4.pixi_id 
    @invoice4.save!
    sleep 2
    @invoice5 = @user.invoices.build FactoryGirl.attributes_for(:invoice, buyer_id: @person.id, status: 'unpaid')
    @details5 = @invoice5.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: @listing4.pixi_id 
    @details6 = @invoice5.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: @listing.pixi_id 
    @invoice5.save!
    sleep 2
    @invoice7 = @buyer.invoices.build FactoryGirl.attributes_for(:invoice, buyer_id: @user.id, status: 'declined')
    @details7 = @invoice7.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: @listing4.pixi_id 
    @invoice7.save!
  end

  def unknown_buyer
    fill_in "buyer_name", :with => "Ed Wilson"
    click_button 'Send'
  end

  def zero_price
    fill_in 'inv_price1', with: 0
    click_button 'Send'
    page.should_not have_content "Less Convenience Fee"
  end

  describe "Check menu invoice link", base: true do
    before do
      px_user = create :pixi_user
      init_setup px_user
      visit root_path 
    end

    describe 'user has no pixis' do
      it { should_not have_link('Bill', href: new_invoice_path) }
    end
  end

  describe 'user has pixis w/o bank acct', base: true do
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

  describe 'user has pixis w bank acct', base: true  do
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

  describe "Seller checks invoices", base: true do
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

  describe "Sent Invoices", sent: true do
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
      page.should have_link('Remove', href: remove_invoice_path(@invoice)) 
    end
  end

  describe "View Paid Invoice", sent: true do
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

  describe "Edit Invoice", process: true do
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
      fill_in 'inv_price1', with: 215.00
      expect { 
	    click_button 'Send'; sleep 3
	}.to change(Invoice, :count).by(0)
      page.should have_content "Status" 
    end
        
    it 'removes invoice', js: true  do
      page.should have_link("#{@invoice.id}", href: invoice_path(@invoice)) 
      visit invoice_path(@invoice)
      page.should have_link('Remove', href: remove_invoice_path(@invoice)) 
      click_remove_cancel
      page.should have_link('Remove', href: remove_invoice_path(@invoice)) 

      click_remove_ok
      sleep 2
      page.should_not have_link("#{@invoice.id}", href: invoice_path(@invoice)) 
      expect(Invoice.find(@invoice.id).status).to eq('removed')
    end
        
    it 'removes a pixi', js: true  do
      visit invoice_path(@invoice5)
      page.should have_link('Edit', href: edit_invoice_path(@invoice5)) 
      click_on 'Edit'
      sleep 2
      page.should have_content @listing.title
      page.should have_selector('.add-row-btn')
      page.should have_selector('.remove-row-btn')
      page.find('.remove-row-btn').click
      accept_btn
      page.should_not have_content @listing4.title
    end
  end

  describe "Received Invoices w/o Invoices", base: true do
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

  describe "Received Invoices w/ Invoices", base: true do
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
      page.should_not have_button "Decline"
      page.should_not have_selector('#pay-btn') 
    end

    it "shows unpaid received invoices", js: true do
      page.should have_link('Received', href: received_invoices_path) 
      click_link 'Received'
      page.should have_link("#{@invoice4.id}", href: invoice_path(@invoice4)) 

      visit invoice_path(@invoice4)
      page.should have_content "Trek Bike" 
      page.should have_button "Decline"
      page.should have_selector('#pay-btn', visible: true) 
    end

    it "shows declined received invoices", js: true do
      page.should have_link('Received', href: received_invoices_path) 
      click_link 'Received'
      page.should have_link("#{@invoice7.id}", href: invoice_path(@invoice7)) 

      visit invoice_path(@invoice7)
      page.should have_content "Trek Bike" 
      page.should_not have_button "Decline"
      page.should_not have_selector('#pay-btn', visible: true) 
    end
  end

  describe "Manage Invoices", process: true do
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
      before :each, run: true do
	select_buyer
	select_pixi @listing
	set_buyer_id
        fill_in 'inv_price1', with: "40"
      end

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
	  select_pixi @listing
	  click_button 'Send'
          page.should have_content "Buyer can't be blank" 
        end
        
        it 'should not accept bad sales tax', run: true do
          fill_in 'inv_tax', with: "R0"
	  expect { 
	    click_button 'Send'
	  }.to change(Invoice, :count).by(0)
        end
        
        it 'does not accept invalid sales tax', run: true  do
          fill_in 'inv_tax', with: 5000
	  expect { 
	    click_button 'Send'
	  }.to change(Invoice, :count).by(0)
        end
        
        it 'does not accept invalid shipping amt', js: true do
          stub_const("MAX_SHIP_AMT", 500)
          expect(MAX_SHIP_AMT).to eq(500)
	  select_buyer
	  select_pixi @listing
          fill_in 'inv_price1', with: 40
	  page.execute_script("$('#ship_amt').val('5000.00');")
	  expect { 
	    click_button 'Send'
	  }.to change(Invoice, :count).by(0)
        end

        it 'rejects invoice with no price before accepting it' do
	  add_data
          fill_in 'inv_price1', with: 0
	  expect { 
	    click_button 'Send'; sleep 3
	  }.to change(Invoice, :count).by(0)
          fill_in 'inv_price1', with: 100
	  expect { 
	    click_button 'Send'; sleep 3
	  }.to change(Invoice, :count).by(1)
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
        
        it 'accepts invoice w/o sales tax', run: true  do
	  expect { 
	    click_button 'Send'; sleep 3
	  }.to change(Invoice, :count).by(1)
	  page.should have_content "Status" 
	  page.should have_content "Bob Jones" 
        end
        
        it 'accepts invoice changes quantity', run: true  do
	  expect { 
            fill_in 'inv_price1', with: "100"
            select("4", :from => 'inv_qty1')
	    click_link 'OK'
	    click_button 'Send'; sleep 3
	  }.to change(Invoice, :count).by(1)
	  page.should have_content "$400.00" 
	  page.should have_content "Status" 
	  page.should have_content "Bob Jones" 
        end
        
        it 'accepts invoice w/ shipping', run: true do
          fill_in 'inv_tax', with: 8.25
	  page.execute_script("$('#ship_amt').val('9.99');")
	  expect { 
	    click_button 'Send'; sleep 3
	  }.to change(Invoice, :count).by(1)
	  page.should have_content "Status" 
	  page.should have_content "Shipping" 
	  page.should have_content "$9.99" 
	  page.should have_content "Bob Jones" 
        end

        it 'accepts invoice with pixi post' do
	  select_buyer
	  select_pixi @pxp_listing
	  set_buyer_id
          fill_in 'inv_price1', with: "40"
	  expect { 
	    click_button 'Send'; sleep 5
	  }.to change(Invoice, :count).by(1)

	  page.should have_content "Status" 
	  page.should have_content "Bob Jones" 
          page.should have_content "#{@pxp_listing.seller_name}"
        end

        it 'accepts invoice with free pixi' do
	  select_buyer
	  select_pixi @free
	  set_buyer_id
          fill_in 'inv_price1', with: "40"
	  expect { 
	    click_button 'Send'; sleep 5
	  }.to change(Invoice, :count).by(1)
	  page.should have_content "Status" 
	  page.should have_content "Bob Jones" 
          page.should have_content "#{@free.seller_name}"
        end

	it 'handles multiple pixis', run: true do
          page.should have_selector('.add-row-btn')
          page.should have_selector('.remove-row-btn')
          page.find('.add-row-btn').click
          select_pixi @pixi, 'pixi_id2'
	  set_buyer_id
          fill_in 'inv_price2', with: "0"
	  expect { 
	    click_button 'Send'; sleep 5
	  }.to change(Invoice, :count).by(1)
	  page.should have_content "Macbook" 
	  page.should have_content "Bob Jones" 
	end

	it 'handles multiple pixis w/ free item', run: true do
          page.should have_selector('.add-row-btn')
          page.should have_selector('.remove-row-btn')
          page.find('.add-row-btn').click
          select_pixi @free, 'pixi_id2'
	  set_buyer_id
	  expect { 
	    click_button 'Send'; sleep 5
	  }.to change(Invoice, :count).by(1)
	  page.should have_content @free.title
	end
      end
    end
  end

  describe "Check Sold Invoices" do
    before do
      init_setup user
      add_paid_invoice false
      @buyer.pixi_wants.create FactoryGirl.attributes_for :pixi_want, pixi_id: @listing.pixi_id
      sleep 2;
    end
        
    it 'invoice w/ selected buyer & sold pixi', js: true do
      expect(@user.has_pixis?).to be_false
      visit new_invoice_path(buyer_id: @buyer.id, pixi_id: @listing.pixi_id)
      page.should_not have_selector "#buyer_name"
      page.should have_content "Status"
      page.should have_content NO_INV_PIXI_MSG
      page.should have_content @listing.title
      page.should have_content @buyer.name
    end
  end

end
