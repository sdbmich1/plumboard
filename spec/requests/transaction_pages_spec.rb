require 'spec_helper'

feature "Transactions" do
  subject { page }
  let(:user) { FactoryGirl.create(:pixi_user) }
  let(:submit) { "Done!" }

  before(:each) do
    login_as(user, :scope => :user, :run_callbacks => false)
    FactoryGirl.create :state
    @user = user
    @listing = FactoryGirl.create :temp_listing, seller_id: @user.id
  end

  def add_invoice
    @seller = FactoryGirl.create(:pixi_user, first_name: 'Kim', last_name: 'Harris', email: 'kharris@pixitest.com')
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
    fill_in 'transaction_address', with: '251 Connecticut'
    fill_in 'transaction_city', with: 'San Francisco'
  end

  def user_data_with_state
    user_data
    select("California", :from => "transaction_state")
    fill_in 'transaction_zip', with: '94103'
  end

  def invalid_card_dates
    select "January", from: "card_month"
    select (Date.today.year).to_s, from: "card_year"
  end

  def valid_card_dates
    select "January", from: "card_month"
    select (Date.today.year+2).to_s, from: "card_year"
  end

  def credit_card val="4242424242424242"
    fill_in "card_number", with: val
  end

  def credit_card_data cid="4242424242424242", cvv="123", valid=true
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
      FactoryGirl.create :promo_code
      visit_free_txn_path 
    end

    it { should have_link('Prev', href: temp_listing_path(@listing)) }
    it { should have_link('Cancel', href: temp_listing_path(@listing)) }
    it { should have_button('Done!') }

    it "Reviews a pixi" do
      expect { 
	      click_link 'Prev'
	}.not_to change(Transaction, :count)

      page.should have_content "Review Your Pixi" 
    end

    describe "Manage Free Valid Transactions", js: true do

      it "Cancel transaction cancel" do
        expect { 
          click_cancel_cancel
	}.not_to change(Transaction, :count)

        page.should have_content "Submit Your Order" 
      end
 
      it "should create a transaction with 100% discount" do
       user_data_with_state
        expect { 
          click_ok; sleep 2
	}.to change(Transaction, :count).by(1)

        page.should have_content "Order Complete"
      end

      it "Cancel transaction" do
        click_cancel_ok

        page.should_not have_content "Total Due"
        page.should have_content "Successfully removed pixi" 
      end
    end
  end

  describe "Manage Valid Invoice Transactions" do
    before(:each) do
      visit_inv_txn_path 
      user_data_with_state
    end

    it { should have_selector('title', text: 'Pay Invoice') }
    it { should have_content "Invoice # #{@invoice.id} from #{@seller.name}" }
    it { should have_content @invoice.pixi_title }
    it { should have_link('Prev', href: invoice_path(@invoice)) }
    it { should_not have_link('Cancel', href: temp_listing_path(@listing)) }
    it { should have_button('Done!') }

    it "Reviews an invoice" do
      expect { 
	      click_link 'Prev'
	}.not_to change(Transaction, :count)

      page.should have_selector('title', text: 'Invoices')
      page.should have_content "INVOICE" 
    end

    it "creates a stripe transaction with valid visa card", :js=>true do
      CREDIT_CARD_API = 'stripe'
      expect { 
        credit_card_data
	}.to change(Transaction, :count).by(1)

      page.should have_content("Purchase Complete")
    end

    it "creates a balanced transaction with valid visa card", :js=>true do
      expect { 
        credit_card_data '4111111111111111'
        page.should have_content("Purchase Complete")
      }.to change(Transaction, :count).by(1)
    end

    it "creates a balanced transaction with valid mc card", :js=>true do
      expect { 
        credit_card_data '5105105105105100'
        page.should have_content("Purchase Complete")
      }.to change(Transaction, :count).by(1)
    end

    it "creates a balanced transaction with valid amex card", :js=>true do
      expect { 
        credit_card_data '341111111111111', '1234'
        page.should have_content("Purchase Complete")
      }.to change(Transaction, :count).by(1)
    end
  end

  describe 'pay invoice from post page' do
    before :each do
      add_invoice
      visit posts_path
    end

    it { should have_button('Pay') }

    it "creates a balanced transaction with valid card", :js=>true do
      click_on 'Pay'
      page.should have_content 'Pay Invoice'
      page.should have_content 'Total Due'

      expect { 
        user_data_with_state
        credit_card_data '5105105105105100'
        page.should have_content("Purchase Complete")
      }.to change(Transaction, :count).by(1)
    end
  end

  describe "Manage Invalid Invoice Transactions" do
    before(:each) do
      visit_inv_txn_path 
      user_data_with_state
    end

    it "should not create a transaction with no card #", :js=>true do
      expect { 
	  credit_card_data '', '123', true
	  click_ok }.not_to change(Transaction, :count)
      page.should have_content 'invalid'
    end

    it "should not create a transaction with invalid card #", :js=>true do
      expect { 
	  credit_card_data '4444444444444448', '123', true
	  click_ok }.not_to change(Transaction, :count)
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

  describe "Manage Valid Pixi Transactions" do
    before(:each) do
      visit_txn_path 
      user_data_with_state
    end

    it "Cancel transaction submission", :js=>true do
      expect { 
	click_submit_cancel      
      }.not_to change(Transaction, :count)
      page.should have_content "Submit Your Pixi" 
    end

    it "should create a transaction with valid visa card", :js=>true do
      expect { 
        credit_card_data 
      }.to change(Transaction, :count).by(1)
      page.should have_content("your pixi will be posted")
    end

    it "should create a transaction with valid mc card", :js=>true do
      expect { 
        credit_card_data "5555555555554444"
	}.to change(Transaction, :count).by(1)
      page.should have_content("your pixi will be posted")
    end

    it "should create a transaction with valid ax card", :js=>true do
      expect { 
        credit_card_data "378282246310005"
	}.to change(Transaction, :count).by(1)
      page.should have_content("your pixi will be posted")
    end

    it "should create a transaction with valid discover card", :js=>true do
      expect { 
        credit_card_data "6011000990139424"
	}.to change(Transaction, :count).by(1)
      page.should have_content("your pixi will be posted")
    end

    it "should create a transaction with valid diners card", :js=>true do
      expect { 
        credit_card_data "6011000990139424"
	}.to change(Transaction, :count).by(1)
      page.should have_content("your pixi will be posted")
    end

    it "should create a transaction with valid jcb card", :js=>true do
      expect { 
        credit_card_data "3530111333300000"
	}.to change(Transaction, :count).by(1)
      page.should have_content("your pixi will be posted")
    end
  end

  describe "Manage Invalid Transactions", :js=>true do
    before { visit_txn_path }

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
          fill_in 'transaction_zip', with: ""
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

      it "should not create a transaction with expired card" do
        expect { 
	  credit_card_data '4000000000000069', '123', true
	  click_ok }.not_to change(Transaction, :count)
      end

      it "should not create a transaction with declined card" do
        expect { 
	  credit_card_data '4000000000000002', '123', true
	  click_ok }.not_to change(Transaction, :count)
      end

      it "should not create a transaction with bad_cvv card" do
        expect { 
	  credit_card_data '4242424242424242', '12', true
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'invalid'
      end

      it "should not create a transaction with bad_dates card" do
        expect { 
	  credit_card_data '4242424242424242', '123', false
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'invalid'
      end

      it "should not create a transaction with error card" do
        expect { 
	  credit_card_data '4000000000000119', '123', false
	  click_ok }.not_to change(Transaction, :count)
      end
    end

    describe "Create with invalid Mastercard information" do
      before { user_data_with_state }

      it "should not create a transaction with bad_cvv card" do
        expect { 
          credit_card_data "5555555555554444", '12', true
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'invalid'
      end

      it "should not create a transaction with bad_dates card" do
        expect { 
          credit_card_data "5555555555554444", '123', false
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'invalid'
      end
    end

    describe "Create with invalid amex information" do
      before { user_data_with_state }

      it "should not create a transaction with bad_cvv card" do
        expect { 
          credit_card_data "378282246310005", '12', true
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'invalid'
      end

      it "should not create a transaction with bad_dates card" do
        expect { 
          credit_card_data "378282246310005", '123', false
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'invalid'
      end
    end

    describe "Create with invalid Discover information" do
      before { user_data_with_state }

      it "should not create a transaction with bad_cvv card" do
        expect { 
          credit_card_data "6011000990139424", '12', true
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'invalid'
      end

      it "should not create a transaction with bad_dates card" do
        expect { 
          credit_card_data "6011000990139424", '123', false
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'invalid'
      end
    end

    describe "Create with invalid Diners information" do
      before { user_data_with_state }

      it "should not create a transaction with bad_cvv card" do
        expect { 
          credit_card_data "6011000990139424", '12', true
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'invalid'
      end

      it "should not create a transaction with bad_dates card" do
        expect { 
          credit_card_data "6011000990139424", '123', false
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'invalid'
      end
    end

    describe "Create with invalid JCB information" do
      before { user_data_with_state }

      it "should not create a transaction with bad_cvv card" do
        expect { 
          credit_card_data "3530111333300000", '12', true
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'invalid'
      end

      it "should not create a transaction with bad_dates card" do
        expect { 
          credit_card_data "3530111333300000", '123', false
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'invalid'
      end
    end
  end
end

