require 'spec_helper'

feature "Transactions" do
  subject { page }
  let(:user) { FactoryGirl.create(:pixi_user) }
  let(:contact_user) { FactoryGirl.create(:contact_user) }
  let(:submit) { "Done!" }

  before(:each) do
    FactoryGirl.create :state
    FactoryGirl.create :promo_code
  end

  def init_setup usr
    login_as(usr, :scope => :user, :run_callbacks => false)
    @user = usr
    @listing = FactoryGirl.create :temp_listing, seller_id: @user.id, status: nil
  end

  def add_invoice
    @seller = FactoryGirl.create(:pixi_user)
    @listing2 = FactoryGirl.create(:listing, seller_id: @seller.id)
    @account = @seller.bank_accounts.create FactoryGirl.attributes_for :bank_account, status: 'active'
    @invoice = @seller.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing2.pixi_id, buyer_id: @user.id, 
      bank_account_id: @account.id)
  end

  def visit_txn_path
    visit new_transaction_path id: @listing.pixi_id, promo_code: '', title: @listing.title, 
        "item1" => 'New Pixi Post', "quantity1" => 1, cnt: 1, qtyCnt: 1, "price1" => 5.00, transaction_type: 'pixi'
  end

  def visit_free_txn_path
    visit new_transaction_path id: @listing.pixi_id, promo_code: '2013LAUNCH', title: @listing.title,
        "item1" => 'New Pixi Post', "quantity1" => 1, cnt: 1, qtyCnt: 1, "price1" => 5.00, transaction_type: 'pixi'
  end

  def visit_inv_txn_path
    add_invoice
    visit new_transaction_path id: @invoice.pixi_id, promo_code: '', title: "Invoice # #{@invoice.id}", seller: @seller.name,
        "item1" => @invoice.pixi_title, "quantity1" => 1, cnt: 1, qtyCnt: 1, "price1" => 100.00, transaction_type: 'invoice',
	"sales_tax"=> 8.25, "invoice_id"=> @invoice.id
  end

  def user_data
    fill_in 'first_name', with: @user.first_name
    fill_in 'last_name', with: @user.last_name
    fill_in 'transaction_email', with: @user.email
    fill_in 'transaction_home_phone', with: '4152419755'
    fill_in 'transaction_address', with: '251 Connecticut St'
    fill_in 'transaction_city', with: 'San Francisco'
  end

  def user_data_with_state
    user_data
    select("California", :from => "transaction_state")
    fill_in 'postal_code', with: '94103'
  end

  def invalid_card_dates
    select "January", from: "card_month"
    select (Date.today.year).to_s, from: "card_year"
  end

  def valid_card_dates
    select "January", from: "card_month"
    select (Date.today.year+2).to_s, from: "card_year"
  end

  def credit_card val="4111111111111111"
    fill_in "card_number", with: val
  end

  def credit_card_data cid="4111111111111111", cvv="123", valid=true
    credit_card cid
    fill_in "card_code",  with: cvv
    valid ? valid_card_dates : invalid_card_dates
    click_valid_ok
  end

  def user_login
    fill_in "Email", with: @user.email
    fill_in "Password", with: @user.password
    click_button "Sign in"
  end

  def click_ok
    click_button submit 
    page.driver.browser.switch_to.alert.accept
  end

  def click_valid_ok
    click_button submit 
    page.driver.browser.switch_to.alert.accept
    sleep 3
  end

  def click_cancel_ok
    click_link 'Cancel'
    page.driver.browser.switch_to.alert.accept
  end

  def click_cancel_cancel
    click_link 'Cancel'
    page.driver.browser.switch_to.alert.dismiss
  end

  def click_submit_cancel
    click_button submit 
    page.driver.browser.switch_to.alert.dismiss
  end

  describe "Manage Free Valid Transactions" do
    before(:each) do 
      init_setup user
      visit_free_txn_path 
    end

    it 'shows content' do
      page.should have_link('Prev', href: temp_listing_path(@listing))
      page.should have_link('Cancel', href: temp_listing_path(@listing))
      page.should have_button('Done!')
    end

    it "Reviews a pixi" do
      expect { 
	      click_link 'Prev'
	}.not_to change(Transaction, :count)
      page.should have_content "Review Your Pixi" 
    end

    describe "Cancel Free Valid Transactions", js: true do

      it "Cancels transaction cancel" do
        expect { 
          click_cancel_cancel
	}.not_to change(Transaction, :count)

        page.should have_content "Total Due" 
      end
 
      it "creates a transaction with 100% discount" do
       user_data_with_state
        expect { 
          click_ok; sleep 2
	}.to change(Transaction, :count).by(1)
        page.should have_content "has been submitted"
      end

      it "Cancels transaction" do
        click_cancel_ok
        page.should_not have_content "Total Due"
        page.should have_content "Home" 
      end
    end
  end

  describe "Manage Valid Invoice Transactions - new card" do
    before(:each) do
      init_setup user
      visit_inv_txn_path 
      user_data_with_state
    end

    it 'shows content' do
      page.should have_selector('title', text: 'PixiPay')
      page.should have_content "Invoice # #{@invoice.id} from #{@seller.name}"
      page.should have_content @invoice.pixi_title
      page.should have_content "Total Due"
      page.should have_selector('.addr-tbl', visible: false)
      page.should have_selector('#edit-txn-addr', visible: false)
      page.should_not have_content "Payment Information"
      page.should_not have_selector('#edit-card-btn', visible: false)
      page.should have_link('Prev', href: invoice_path(@invoice))
      page.should_not have_link('Cancel', href: temp_listing_path(@listing))
      page.should have_button('Done!')
    end

    it "Reviews an invoice" do
      expect { 
	click_link 'Prev'
      }.not_to change(Transaction, :count)
      page.should have_selector('title', text: 'Invoices')
      page.should have_content "INVOICE" 
    end

    it "creates a balanced transaction with valid visa card", :js=>true do
      expect { 
        credit_card_data '4111111111111111'
        page.should have_content("Purchase Complete")
        page.should have_content("Please Rate Your Seller")
        page.should have_link('Add Comment', href: '#') 
      }.to change(Transaction, :count).by(1)
    end

    it "creates a balanced transaction with valid mc card", :js=>true do
      expect { 
        credit_card_data '5105105105105100'
        page.should have_content("Purchase Complete")
        page.should have_content("Please Rate Your Seller")
        page.should have_link('Add Comment', href: '#') 
      }.to change(Transaction, :count).by(1)
    end

    it "creates a balanced transaction with valid amex card", :js=>true do
      expect { 
        credit_card_data '341111111111111', '1234'
        page.should have_content("Purchase Complete")
        page.should have_link('Add Comment', href: '#') 
      }.to change(Transaction, :count).by(1)
    end

    it "sets seller rating", js: true do
      expect { 
        credit_card_data '341111111111111', '1234'
        page.should have_content("Purchase Complete")
        page.should have_link('Add Comment', href: '#') 
        page.should have_selector('#rateit5', visible: true) 
        page.should have_selector('.cmt-descr', visible: false) 
        page.find('#rateit5').click
        page.find('#done-btn').click; sleep 3
      }.to change(Transaction, :count).by(1)
    end
  end

  describe "Valid Invoice Transactions w/ invalid card" do
    before(:each) do
      init_setup user
      @acct = @user.card_accounts.create FactoryGirl.attributes_for(:card_account, status: 'active', expiration_year: Date.today.year-1)
      visit_inv_txn_path 
      user_data_with_state
    end

    it 'shows content' do
      page.should have_content "Total Due"
      page.should have_selector('.addr-tbl', visible: false)
      page.should have_selector('#edit-txn-addr', visible: false)
      page.should_not have_content "Payment Information"
      page.should_not have_selector('#edit-card-btn', visible: false)
      page.should have_link('Prev', href: invoice_path(@invoice))
      page.should_not have_link('Cancel', href: temp_listing_path(@listing))
      page.should have_button('Done!')
    end

    it "creates a balanced transaction with valid mc card", :js=>true do
      expect { 
        credit_card_data '5105105105105100'
        page.should have_content("Purchase Complete")
        page.should have_content("Please Rate Your Seller")
        page.should have_link('Add Comment', href: '#') 
      }.to change(Transaction, :count).by(1)
    end
  end

  describe "Valid Invoice Transactions w/ existing card" do
    before(:each) do
      usr = FactoryGirl.create(:contact_user) 
      init_setup usr
      @acct = @user.card_accounts.create FactoryGirl.attributes_for :card_account, card_no: '1111'
      visit_inv_txn_path 
    end

    it 'shows content' do
      page.should have_selector('title', text: 'PixiPay')
      page.should have_content "Invoice # #{@invoice.id} from #{@seller.name}"
      page.should have_content @invoice.pixi_title
      page.should have_content "Total Due"
      page.should have_content "Buyer Information"
      page.should have_content @user.contacts[0].address
      page.should have_content @user.contacts[0].city
      page.should have_content @user.contacts[0].state
      page.should have_content @user.contacts[0].zip
      page.should have_selector('#edit-txn-addr', visible: false)
      page.should have_content "Payment Information"
      page.should have_selector('#edit-card-btn', visible: true)
      page.should have_link('Prev', href: invoice_path(@invoice))
      page.should have_button('Done!')
    end

    it "edits the buyer info" do
      expect { 
        page.find('#edit-txn-addr').click
        fill_in 'transaction_home_phone', with: '4152415555'
        page.should have_content("Address")
        page.should have_content("City")
        page.should have_content("Zip")
      }.to change(Transaction, :count).by(0)
    end

    it "edits the payment info" do
      expect { 
        page.find('#edit-card-btn').click; sleep 1
        fill_in "card_number", with: '5105105105105100'
        page.should have_content("Credit Card #")
        page.should have_content("Code")
      }.to change(Transaction, :count).by(0)
    end

    it "submits payment", js: true do
      expect { 
        click_valid_ok
        page.should have_content("Purchase Complete")
        page.should have_link('Add Comment', href: '#') 
        page.should have_selector('#rateit5', visible: true) 
        page.should have_selector('.cmt-descr', visible: false) 
      }.to change(Transaction, :count).by(1)
    end
  end

  describe "Invalid Invoice Transactions" do
    before(:each) do
      usr = FactoryGirl.create(:pixi_user) 
      init_setup usr
      visit_inv_txn_path 
      user_data_with_state
    end

    it "should not create a transaction with no card #", :js=>true do
      expect { 
	  credit_card_data '', '123', true
      }.not_to change(Transaction, :count)
      page.should have_content 'invalid'
    end

    it "should not create a transaction with invalid card #", :js=>true do
      expect { 
	  credit_card_data '4444444444444448', '123', true
      }.not_to change(Transaction, :count)
      page.should have_content 'invalid'
    end

    it "should not create a transaction with bad card #", :js=>true do
      expect { 
	  credit_card_data '6666666666666666', '123', true
	  click_ok }.not_to change(Transaction, :count)
      page.should have_content 'invalid'
    end

    it "should not create a transaction with no cvv", :js=>true do
      expect { 
	  credit_card_data '4242424242424242', '', true
	  click_ok }.not_to change(Transaction, :count)
      page.should have_content 'invalid'
    end

    it "should not create a transaction with bad_dates card", :js=>true do
      expect { 
	  credit_card_data '4242424242424242', '123', false
	  click_ok }.not_to change(Transaction, :count)
      page.should have_content 'invalid'
    end

    it "creates a transaction after bad_dates error", :js=>true do
      expect { 
	  credit_card_data '4242424242424242', '123', false
	  click_ok }.not_to change(Transaction, :count)
      page.should have_content 'invalid'

      expect { 
        credit_card_data '4111111111111111'
        page.should have_content("Purchase Complete")
      }.to change(Transaction, :count).by(1)
    end
  end

  describe "Valid Pixi Transactions" do
    before(:each) do
      usr = FactoryGirl.create(:pixi_user) 
      init_setup usr
      visit_txn_path 
      user_data_with_state
    end

    it "Cancel transaction submission", :js=>true do
      expect { 
	click_submit_cancel      
      }.not_to change(Transaction, :count)
      page.should have_content "Submit Your Pixi" 
    end
  end

  describe "Manage Invalid Transactions", :js=>true do
    before(:each) do
      usr = FactoryGirl.create(:pixi_user) 
      init_setup usr
      visit_txn_path 
    end

    describe "Create with invalid address information" do
      it "should not create a transaction with invalid first name" do
        expect { 
          user_data_with_state
          fill_in 'first_name', with: ""
          credit_card_data
	  click_ok }.not_to change(Transaction, :count)
        page.should have_content "First name can't be blank"
      end

      it "should not create a transaction with invalid last name" do
        expect { 
          user_data_with_state
          fill_in 'last_name', with: ""
          credit_card_data
	  click_ok }.not_to change(Transaction, :count)
        page.should have_content "Last name can't be blank"
      end

      it "should not create a transaction with blank home phone" do
        expect { 
	  user_data_with_state
          fill_in 'transaction_home_phone', with: ""
          credit_card_data
	  click_ok }.not_to change(Transaction, :count)
        page.should have_content "Home phone can't be blank"
      end
    end

    describe "Create with invalid email information" do
      it "should not create a transaction with blank email" do
        expect { 
	  user_data_with_state
          fill_in 'transaction_email', with: ""
          credit_card_data
	  click_ok }.not_to change(Transaction, :count)
        page.should have_content "Email can't be blank"
      end

      it "should not create a transaction with bad email" do
        expect { 
	  user_data_with_state
          fill_in 'transaction_email', with: "user@x."
          credit_card_data
	  click_ok }.not_to change(Transaction, :count)
        page.should have_content 'Email is not formatted properly'
      end
    end

    describe "Create with invalid address information" do
      it "should not create a transaction w/o address" do
        expect { 
          fill_in 'first_name', with: @user.first_name
          fill_in 'last_name', with: @user.last_name
    	  fill_in 'transaction_email', with: @user.email
          credit_card_data
	  click_ok }.not_to change(Transaction, :count)
        page.should have_content "Address can't be blank"
      end

      it "should not create a transaction with no street address" do
        expect { 
	  user_data_with_state
          fill_in 'transaction_address', with: ""
          credit_card_data
	  click_ok }.not_to change(Transaction, :count)
        page.should have_content "Address can't be blank"
      end

      it "should not create a transaction with no city" do
        expect { 
	  user_data_with_state
          fill_in 'transaction_city', with: ""
          credit_card_data
	  click_ok }.not_to change(Transaction, :count)
        page.should have_content "City can't be blank"
      end

      it "should not create a transaction with no state" do
        expect { 
	  user_data
          credit_card_data
	  click_ok }.not_to change(Transaction, :count)
        page.should have_content "State can't be blank"
      end

      it "should not create a transaction with no zip" do
        expect { 
	  user_data_with_state
          fill_in 'postal_code', with: ""
          credit_card_data
	  click_ok }.not_to change(Transaction, :count)
        page.should have_content "Zip can't be blank"
      end
    end

    describe "Create with invalid Visa card information" do
      before { user_data_with_state }

      it "should not create a transaction with no card #" do
        expect { 
	  credit_card_data nil
	  click_ok }.not_to change(Transaction, :count)
        page.should have_content 'invalid'
      end

      it "should not create a transaction with no cvv" do
        expect { 
	  credit_card_data '4242424242424242', nil, true
	  click_ok }.not_to change(Transaction, :count)
        page.should have_content 'invalid'
      end
    end
  end
end

