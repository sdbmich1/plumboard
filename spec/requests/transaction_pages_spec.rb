require 'spec_helper'

feature "Transactions" do
  subject { page }
  let(:user) { create(:pixi_user) }
  let(:site) { create(:site) }
  let!(:state) { create(:state) }
  let(:contact_user) { create(:contact_user) }
  let(:submit) { "Done!" }
  let(:save) { "Save" }

  before :each do
    create :promo_code
  end

  def page_setup usr
    init_setup usr
    stub_const("PIXI_PERCENT", 2.9)
    stub_const("EXTRA_PROCESSING_FEE", 0.30)
    stub_const("PXB_TXN_PERCENT", 0.25)
    stub_const("PIXI_FEE", 0.99)
    @listing = create :temp_listing, seller_id: @user.id, quantity: 1
  end

  def add_invoice mFlg=false, ship_amt=0.0
    @seller = create(:pixi_user, acct_token: "acct_16HJbsDEdnXv7t4y")
    @listing2 = create(:listing, seller_id: @seller.id, title: 'Leather Coat', quantity: 2)
    @account = @seller.bank_accounts.create attributes_for :bank_account, status: 'active'
    @invoice = @seller.invoices.build attributes_for(:invoice,
      buyer_id: @user.id, bank_account_id: @account.id, ship_amt: ship_amt)
    @details = @invoice.invoice_details.build attributes_for :invoice_detail, pixi_id: @listing.pixi_id 
    @details2 = @invoice.invoice_details.build attributes_for :invoice_detail, pixi_id: @listing2.pixi_id if mFlg
    @invoice.save!
  end

  def visit_txn_path
    visit new_transaction_path id1: @listing.pixi_id, promo_code: '', title: 'New Pixi',
        "item1" => @listing.title, "quantity1" => 1, cnt: 1, qtyCnt: 1, "price1" => 5.00, transaction_type: 'pixi'
  end

  def visit_free_txn_path
    visit new_transaction_path id1: @listing.pixi_id, promo_code: '2013LAUNCH', title: 'New Pixi',
        "item1" => @listing.title, "quantity1" => 1, cnt: 1, qtyCnt: 1, "price1" => 5.00, transaction_type: 'pixi'
  end

  def visit_inv_txn_path ship=0.0
    add_invoice(false, ship)
    visit new_transaction_path id1: @listing.pixi_id, promo_code: '', title: "Invoice # #{@invoice.id} from #{@invoice.seller_name}", seller: @seller.name,
        "item1" => @listing.title, "quantity1" => 2, "cnt"=> 1, "qtyCnt"=> 2, "price1" => 185.00, transaction_type: 'invoice',
	"tax_total"=> @invoice.tax_total, "invoice_id"=> @invoice.id, "ship_amt"=> ship, "inv_total"=>@invoice.amount+ship
  end

  def visit_multi_txn_path ship=0.0
    add_invoice true
    visit new_transaction_path id1: @listing.pixi_id, promo_code: '', title: "Invoice # #{@invoice.id} from #{@invoice.seller_name}", seller: @seller.name,
        "item1" => @listing.title, "quantity1" => 1, cnt: 2, "qtyCnt"=> 2, "price1" => @listing.price, transaction_type: 'invoice',
	tax_total: 8.25, "invoice_id"=> @invoice.id, ship_amt: ship,
        "quantity2"=> 2, "item2"=>@listing2.title, "price2"=> @listing2.price, "id2"=>@listing2.pixi_id,  
        "inv_total"=>(@listing.price*3+8.25+ship), "transaction_type"=>'invoice', "promo_code"=>'' 
  end

  def visit_buy_now_txn_path ship=0.0
    add_invoice(true)
    @listing2.update_attribute(:buy_now_flg, true)
    visit new_transaction_path id1: @listing2.pixi_id, promo_code: '', title: "Invoice # #{@invoice.id} from #{@invoice.seller_name}", seller: @seller.name,
        "item1" => @listing2.title, "quantity1" => 2, "cnt"=> 1, "qtyCnt"=> 2, "price1" => 185.00, transaction_type: 'invoice',
        "tax_total"=> @invoice.tax_total, "invoice_id"=> @invoice.id, "ship_amt"=> ship, "inv_total"=>@invoice.amount+ship
  end

  def user_data home_phone
    fill_in 'first_name', with: @user.first_name
    fill_in 'last_name', with: @user.last_name
    fill_in 'transaction_email', with: @user.email
    fill_in 'transaction_home_phone', with: home_phone
    fill_in 'transaction_address', with: '251 Connecticut St'
    fill_in 'transaction_city', with: 'San Francisco'
  end

  def user_data_with_state home_phone='4152419755'
    user_data home_phone
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

  def valid_dates
    select "January", from: "card_month"
    select (Date.today.year+2).to_s, from: "card_year"
  end

  def load_credit_card cid="4242424242424242", cvv="123", valid=true
    credit_card cid
    fill_in "card_code",  with: cvv
    valid ? valid_dates : invalid_card_dates
    fill_in "card_zip",  with: '94103'
    click_valid_save
  end

  def display_inv_content ship_flg=false
      expect(page).to have_content "Invoice # #{@invoice.id} from #{@seller.name}"
      expect(page).to have_content @invoice.pixi_title
      expect(page).to have_content "Total Due"
      expect(page).to have_content "Buyer Information"
      expect(page).to have_content @user.contacts[0].address
      expect(page).to have_content @user.contacts[0].city
      expect(page).to have_content @user.contacts[0].state
      expect(page).to have_content @user.contacts[0].zip
      if ship_flg
        expect(page).to have_content "Shipping Information"
        expect(page).to have_content @txn.ship_address
        expect(page).to have_content @txn.ship_city
        expect(page).to have_content @txn.ship_state
        expect(page).to have_content @txn.ship_zip
      end
      expect(page).to have_selector('#edit-txn-addr', visible: false)
      expect(page).to have_content "Payment Information"
      expect(page).to have_selector('#edit-card-btn', visible: true)
      expect(page).to have_link('Cancel', href: invoice_path(@invoice))
      expect(page).to have_button('Done!')
  end

  describe "Manage Free Valid Transactions", process: true do
    before(:each) do 
      page_setup user
      visit_free_txn_path 
    end

    it 'shows content' do
      expect(page).to have_link('Cancel', href: temp_listing_path(@listing))
      expect(page).to have_button('Done!')
    end

    it "Reviews a pixi" do
      expect { 
	      click_link 'Cancel'
	}.not_to change(Transaction, :count)
      expect(page).to have_content "Review Your Pixi" 
    end

    describe "Cancel Free Valid Transactions", js: true do

      it "Cancels transaction cancel" do
        expect { 
          click_cancel_cancel
	}.not_to change(Transaction, :count)

        expect(page).to have_content "Total Due" 
      end
 
      it "creates a transaction with 100% discount" do
       user_data_with_state
        expect { 
          ; sleep 2
	}.to change(Transaction, :count).by(1)
        expect(page).to have_content "has been submitted"
      end

      it "Cancels transaction" do
        click_cancel_ok
        expect(page).not_to have_content "Total Due"
        expect(page).to have_content "Pixi" 
      end
    end
  end

  describe "Manage Valid Invoice Transactions w/ shipping", process: true do
    before(:each) do
      page_setup user
      visit_inv_txn_path 9.99
      user_data_with_state
    end

    it 'shows content' do
      expect(page).to have_selector('title', text: 'PixiPay')
      expect(page).to have_content "Invoice # #{@invoice.id} from #{@seller.name}"
      expect(page).to have_content @invoice.pixi_title
      expect(page).to have_selector('.ttip', visible: true)
      expect(page).to have_content "Total Due"
      expect(page).to have_content "Shipping"
      expect(page).to have_content @invoice.ship_amt
      fill_in 'transaction_ship_address', with: '251 Connecticut St'
      fill_in 'transaction_ship_city', with: 'San Francisco'
      select 'California', :from => 'transaction_ship_state'
      fill_in 'transaction_ship_zip', with: '94103'
    end

    it "creates shipping transaction with valid visa card", :js=>true do
      expect { 
        credit_card_data '4242424242424242'
        expect(page).to have_content("Purchase Complete")
      }.to change(Transaction, :count).by(1)
    end
  end

  describe "Manage Valid Invoice Transactions - new card", process: true do
    before(:each) do
      page_setup user
      visit_inv_txn_path 
      user_data_with_state
    end

    it 'shows content', js: true do
      expect(page).to have_content "Invoice # #{@invoice.id} from #{@seller.name}"
      expect(page).to have_content @invoice.pixi_title
      expect(page).to have_selector('.ttip', visible: true)
      expect(page).to have_content "Total Due"
      expect(page).not_to have_content "Shipping"
      expect(page).to have_selector('.addr-tbl', visible: false)
      expect(page).to have_selector('#edit-txn-addr', visible: false)
      expect(page).not_to have_content "Payment Information"
      expect(page).not_to have_selector('#edit-card-btn', visible: false)
      expect(page).to have_link('Cancel', href: invoice_path(@invoice))
      expect(page).to have_button('Done!')
    end

    it "Reviews an invoice" do
      expect { 
	click_link 'Cancel'
      }.not_to change(Transaction, :count)
      expect(page).to have_selector('title', text: 'Invoices')
      expect(page).to have_content "INVOICE" 
    end

    it "creates transaction with valid visa card", :js=>true do
      expect { 
        credit_card_data '4242424242424242'
        expect(page).to have_content("Purchase Complete")
        expect(page).to have_content("Please Rate Your Seller")
        expect(page).to have_link('Add Comment', href: '#') 
      }.to change(Transaction, :count).by(1)
    end

    it "creates transaction with valid mc card", :js=>true do
      expect { 
        credit_card_data '5200828282828210'
        expect(page).to have_content("Purchase Complete")
        expect(page).to have_content("Please Rate Your Seller")
        expect(page).to have_link('Add Comment', href: '#') 
      }.to change(Transaction, :count).by(1)
    end

    it "creates transaction with valid amex card", :js=>true do
      expect { 
        credit_card_data '378282246310005', '1234'
        expect(page).to have_content("Purchase Complete")
        expect(page).to have_link('Add Comment', href: '#') 
      }.to change(Transaction, :count).by(1)
    end

    it "sets seller rating", js: true do
      @site = create :site
      @loc = @site.id
      stub_const("MIN_PIXI_COUNT", 0)
      expect(MIN_PIXI_COUNT).to eq(0)
      expect { 
        credit_card_data '378282246310005', '1234'
        expect(page).to have_content("Purchase Complete")
        expect(page).to have_link('Add Comment', href: '#') 
        expect(page).to have_selector("#rateit5", visible: true) 
        expect(page).to have_selector('.cmt-descr', visible: false) 
        page.find("#rateit5").click
        page.find('#rating-done-btn').click; sleep 3
      }.to change(Transaction, :count).by(1)
      expect(page).to have_content "Pixis" 
    end
  end

  describe "Invoice Transactions", process: true do
    before(:each) do
      page_setup user
      @acct = @user.card_accounts.create attributes_for(:card_account, status: 'active', expiration_year: Date.today.year-1)
      visit_inv_txn_path 
      user_data_with_state
    end

    it 'shows content' do
      expect(page).to have_content "Total Due"
      expect(page).to have_selector('.addr-tbl', visible: false)
      expect(page).to have_selector('#edit-txn-addr', visible: false)
      expect(page).not_to have_content "Payment Information"
      expect(page).not_to have_selector('#edit-card-btn', visible: false)
      expect(page).to have_link('Cancel', href: invoice_path(@invoice))
      expect(page).to have_button('Done!')
    end

    it "creates transaction with valid mc card", :js=>true do
      expect { 
        credit_card_data '5555555555554444'; sleep 2
        expect(page).to have_content("Purchase Complete")
        expect(page).to have_content("Please Rate Your Seller")
        expect(page).to have_link('Add Comment', href: '#') 
      }.to change(Transaction, :count).by(1)
      expect(CardAccount.all.count).to eq 1
    end
  end

  describe "Multi-item Invoice Transactions", process: true do
    before(:each) do
      page_setup user
      visit_multi_txn_path 
      user_data_with_state
    end

    it 'shows content', js: true do
      expect(page).to have_content "Total Due"
      expect(page).to have_content @listing.title
      expect(page).to have_content @listing2.title
      expect(page).to have_selector('.addr-tbl', visible: false)
      expect(page).to have_selector('#edit-txn-addr', visible: false)
      expect(page).not_to have_content "Payment Information"
      expect(page).not_to have_selector('#edit-card-btn', visible: false)
      expect(page).to have_link('Cancel', href: invoice_path(@invoice))
      expect(page).to have_button('Done!')
    end

    it "creates transaction with valid mc card", :js=>true do
      expect { 
        expect(page).to have_content @listing.title
        expect(page).to have_content @listing2.title
        credit_card_data '5555555555554444'; sleep 4
        expect(page).to have_content("Purchase Complete")
        expect(page).to have_content("Please Rate Your Seller")
        expect(page).to have_link('Add Comment', href: '#') 
      }.to change(Transaction, :count).by(1)
    end
  end

  describe "Valid Transaction data w/ existing card", main: true do
    before(:each) do
      usr = create(:contact_user) 
      page_setup usr
      @acct = @user.card_accounts.create attributes_for :card_account, card_no: '4242'
      visit_inv_txn_path 
    end

    it 'shows content', js: true do
      display_inv_content
    end

    it "edits the buyer info" do
      expect { 
        page.find('#edit-txn-addr').click
        fill_in 'transaction_home_phone', with: '4152415555'
        expect(page).to have_content("Address")
        expect(page).to have_content("City")
        expect(page).to have_content("Zip")
      }.to change(Transaction, :count).by(0)
    end

    it "edits the payment info" do
      expect { 
        page.find('#edit-card-btn').click; sleep 1
        fill_in "card_number", with: '5555555555554444'
        expect(page).to have_content("Credit Card #")
        expect(page).to have_content("Code")
      }.to change(Transaction, :count).by(0)
    end
  end

  def add_card_account
      expect(page).to have_content 'Card #'
      expect {
        load_credit_card '4242424242424242'; sleep 2.5
      }.to change(CardAccount, :count).by(1)

      visit_inv_txn_path 
      expect(page).to have_content @user.contacts[0].address
      expect(page).to have_content @user.contacts[0].city
      expect(page).to have_content @user.contacts[0].state
      expect(page).to have_content @user.contacts[0].zip
      expect(page).to have_selector('#edit-txn-addr', visible: false)
      expect(page).to have_content "Payment Information"
      expect(page).to have_selector('#edit-card-btn', visible: true)
      expect(page).to have_link('Cancel', href: invoice_path(@invoice))
  end

  describe "Valid Invoice Transactions w/ existing card", main: true do
    before(:each) do
      usr = create(:contact_user) 
      page_setup usr
      visit new_bank_account_path
      click_link 'Card'
      add_card_account
    end

    it "submits payment", js: true do
      expect { 
        click_valid_ok
        expect(page).to have_content("Purchase Complete")
        expect(page).to have_link('Add Comment', href: '#') 
        expect(page).to have_selector('#rateit5', visible: true) 
        expect(page).to have_selector('.cmt-descr', visible: false) 
      }.to change(Transaction, :count).by(1)
    end

    it "creates transaction with new mc card", :js=>true do
      expect { 
        page.find('#edit-card-btn').click; sleep 1
	credit_card_data '5555555555554444'
        expect(page).to have_content("Purchase Complete")
      }.to change(Transaction, :count).by(1)
      expect(CardAccount.where(user_id: @user.id).count).to eq 2
      expect(@user.card_accounts.get_default_acct.card_no).not_to eq '4444'
    end
  end

  def add_bank_account_data
    fill_in 'routing_number', with: '110000000'
    fill_in 'acct_number', with: '000123456789'
    fill_in 'bank_account_acct_name', with: "SDB Business"
    fill_in 'bank_account_description', with: "My business"
    select("checking", :from => "bank_account_acct_type")
  end

  describe "Valid Invoice Transactions w/ existing bank account", main: true do
    before(:each) do
      usr = create(:contact_user) 
      page_setup usr
      visit new_bank_account_path
      add_bank_account_data
    end

    it "creates transaction with valid amex card", :js=>true do
      expect {
          click_on 'Save'; sleep 3;
      }.to change(BankAccount, :count).by(1)

      visit_inv_txn_path 
      expect { 
        credit_card_data '378282246310005', '1234'
        expect(page).to have_content("Purchase Complete")
        expect(page).to have_link('Add Comment', href: '#') 
      }.to change(Transaction, :count).by(1)
    end
  end

  def setup_accounts
      expect {
          click_on 'Save'; sleep 3;
      }.to change(BankAccount, :count).by(1)
      expect(page).to have_content 'Account #'

      # visit new_bank_account_path
      click_link 'Card'

      expect {
        load_credit_card '4242424242424242'; sleep 2.5
      }.to change(CardAccount, :count).by(1)
      expect(page).to have_content 'Card #'

      visit_inv_txn_path 
  end

  describe "Valid Invoice Transactions w/ existing bank & card account", main: true do
    before(:each) do
      usr = create(:contact_user) 
      page_setup usr
      visit new_bank_account_path
      add_bank_account_data
      setup_accounts
    end

    it "creates transaction with saved card", :js=>true do
      expect { 
        click_valid_ok
        expect(page).to have_content("Purchase Complete")
        expect(page).to have_link('Add Comment', href: '#') 
        expect(page).to have_selector('#rateit5', visible: true) 
        expect(page).to have_selector('.cmt-descr', visible: false) 
      }.to change(Transaction, :count).by(1)
    end

    it "creates transaction with new mc card", :js=>true do
      expect { 
        page.find('#edit-card-btn').click; sleep 1
	credit_card_data '5555555555554444'
        expect(page).to have_content("Purchase Complete")
        expect(page).to have_content("MasterCard")
      }.to change(Transaction, :count).by(1)
      expect(CardAccount.where(user_id: @user.id).count).to eq 2
      expect(@user.card_accounts.get_default_acct.card_no).not_to eq '4444'
    end
  end

  describe "Invalid Invoice Transactions", invalid: true do
    before(:each) do
      usr = create(:pixi_user) 
      page_setup usr
      visit_inv_txn_path 
      user_data_with_state
    end

    it "should not create a transaction with no card #", :js=>true do
      expect { 
	  credit_card_data '', '123', true
      }.not_to change(Transaction, :count)
      expect(page).to have_content 'invalid'
    end

    it "should not create a transaction with invalid card #", :js=>true do
      expect { 
	  credit_card_data '4444444444444448', '123', true
      }.not_to change(Transaction, :count)
      expect(page).not_to have_content("Purchase Complete")
    end

    it "should not create a transaction with bad card #", :js=>true do
      expect { 
	  credit_card_data '6666666666666666', '123', true
	  }.not_to change(Transaction, :count)
      expect(page).to have_content 'invalid'
    end

    it "should not create a transaction with bad card token", :js=>true do
      expect { 
	  credit_card_data '4222222222222220', '123', true
	  }.not_to change(Transaction, :count)
      expect(page).to have_content 'invalid'
    end

    it "should not create a transaction with no cvv", :js=>true do
      expect { 
	  credit_card_data '4242424242424242', '', true
	  }.not_to change(Transaction, :count)
      expect(page).to have_content 'invalid'
    end

    it "should not create a transaction with bad_dates card", :js=>true do
      expect { 
	  credit_card_data '4242424242424242', '123', false
	  }.not_to change(Transaction, :count)
      expect(page).to have_content 'invalid'
    end

    it "creates a transaction after bad_dates error", :js=>true do
      expect { 
	  credit_card_data '4242424242424242', '123', false
	  }.not_to change(Transaction, :count)
      expect(page).to have_content 'invalid'

      expect { 
        credit_card_data '4111111111111111'
        expect(page).to have_content("Purchase Complete")
      }.to change(Transaction, :count).by(1)
    end
  end

  describe "Valid Pixi Transactions", process: true do
    before(:each) do
      usr = create(:pixi_user) 
      page_setup usr
      visit_txn_path 
      user_data_with_state
    end

    it "Cancel transaction submission", :js=>true do
      expect { 
	click_submit_cancel      
      }.not_to change(Transaction, :count)
      expect(page).to have_content "Submit Your Pixi" 
    end
  end

  describe "Manage Invalid Transactions", invalid: true do
    before(:each) do
      usr = create(:pixi_user) 
      page_setup usr
      visit_txn_path 
    end

    context "Create with invalid address information" do
      it "should not create a transaction with invalid first name", :js=>true do
        expect { 
          user_data_with_state
          fill_in 'first_name', with: ""
          credit_card_data
	  }.not_to change(Transaction, :count)
      end

      it "should not create a transaction with invalid last name", :js=>true do
        expect { 
          user_data_with_state
          fill_in 'last_name', with: ""
          credit_card_data
	  }.not_to change(Transaction, :count)
      end

      it "should not create a transaction with blank home phone", :js=>true do
        expect { 
	  user_data_with_state nil
          credit_card_data
	  }.not_to change(Transaction, :count)
      end
    end

    context "Create with invalid email information" do
      it "should not create a transaction with blank email", :js=>true do
        expect { 
	  user_data_with_state
          fill_in 'transaction_email', with: ""
          credit_card_data
	  }.not_to change(Transaction, :count)
      end

      it "should not create a transaction with bad email", :js=>true do
        expect { 
	  user_data_with_state
          fill_in 'transaction_email', with: "user@x."
          credit_card_data
	  }.not_to change(Transaction, :count)
      end
    end

    context "Create with invalid address information" do
      it "should not create a transaction w/o address", :js=>true do
        expect { 
          fill_in 'first_name', with: @user.first_name
          fill_in 'last_name', with: @user.last_name
    	  fill_in 'transaction_email', with: @user.email
          credit_card_data
	  }.not_to change(Transaction, :count)
      end

      it "should not create a transaction with no street address", :js=>true do
        expect { 
	  user_data_with_state
          fill_in 'transaction_address', with: ""
          credit_card_data
	  }.not_to change(Transaction, :count)
      end

      it "should not create a transaction with no city", :js=>true do
        expect { 
	  user_data_with_state
          fill_in 'transaction_city', with: ""
          credit_card_data
	  }.not_to change(Transaction, :count)
      end

      it "should not create a transaction with no state", :js=>true do
        expect { 
	  user_data
          credit_card_data
	  }.not_to change(Transaction, :count)
      end

      it "should not create a transaction with no zip", :js=>true do
        expect { 
	  user_data_with_state
          fill_in 'postal_code', with: ""
          credit_card_data
	  }.not_to change(Transaction, :count)
      end
    end

    context "Create with invalid Visa card information" do
      before { user_data_with_state }

      it "should not create a transaction with no card #", :js=>true do
        expect { 
	  credit_card_data nil
	  }.not_to change(Transaction, :count)
      end

      it "should not create a transaction with no cvv", :js=>true do
        expect { 
	  credit_card_data '4242424242424242', nil, true
	  }.not_to change(Transaction, :count)
      end
    end
  end

  describe "Manage Transactions page without transactions", admin: true do
    before do
      page_setup user
      visit transactions_path
    end

    it "should display 'No transactions found'", js: true do
      expect(page).to have_content 'No transactions found.'
    end

    it "should have a selector for date range", js: true do
      expect(page).to have_selector('#date_range_name', visible: true)
    end

    it "should have Export Options button", js: true do
      expect(page).to have_button 'Export Options'
    end
  end

  describe "Manage Transactions page with transactions", admin: true do
    let(:admin_user) { create :admin }
    before :each do
      @user = create :pixi_user
      @buyer = create(:pixi_user, first_name: 'Lucy', last_name: 'Smith', email: 'lucy.smith@lucy.com')
      @seller = create(:pixi_user, first_name: 'Lucy', last_name: 'Burns', email: 'lucy.burns@lucy.com') 
      @listing = create(:listing, title: 'Couch', seller_id: @user.id, price: 100)
      @invoice = @seller.invoices.build attributes_for(:invoice, buyer_id: @buyer.id)
      @details = @invoice.invoice_details.build attributes_for :invoice_detail, pixi_id: @listing.pixi_id 
      @txn = @user.transactions.create attributes_for(:transaction, transaction_type: 'invoice')
      @invoice.transaction_id, @invoice.status = @txn.id, 'pending'
      @invoice.save!
      @txn.invoices.append(@invoice)
      @txn.save!

      page_setup admin_user
      visit transactions_path
    end

    it "should have table", js: true do
      expect(page).to have_content "Transaction Date"
      expect(page).to have_content "Item Title"
      expect(page).to have_content "Buyer"
      expect(page).to have_content "Seller"
      expect(page).to have_content "Buyer Total"
      expect(page).to have_content "Seller Total"
    end

    it "should display transaction", js: true do
      expect(page).to have_content short_date(@txn.updated_at)
      expect(page).to have_content @txn.pixi_title
      expect(page).to have_content @txn.buyer_name
      expect(page).to have_content @txn.seller_name
      expect(page).to have_content @txn.amt
      expect(page).to have_content @txn.get_invoice.amount - @txn.get_invoice.get_fee(true)
    end

    it "should have a selector for date range", js: true do
      expect(page).to have_selector('#date_range_name', visible: true)
    end

    it "should have Export Options button", js: true do
      expect(page).to have_button 'Export Options'
    end
  end

  describe 'Buy Now Transactions' do
    before :each do
      page_setup user
      visit_buy_now_txn_path 
    end
    it 'Cancel deletes invoice', js: true do
      expect(page).to have_link('Cancel',
        href: invoice_path(id: @invoice.id, status: 'cancel'), method: :delete)
    end
  end
end

