require 'spec_helper'

feature "Transactions" do
  subject { page }
  let(:user) { FactoryGirl.create(:contact_user) }
  let(:submit) { "Done!" }

  before(:each) do
    login_as(user, :scope => :user, :run_callbacks => false)
    user.confirm!
    FactoryGirl.create :state
    @user = user
    @listing = FactoryGirl.create :temp_listing, seller_id: @user.id
  end

  def visit_txn_path
    visit new_transaction_path id: @listing.pixi_id, promo_code: '', title: @listing.title,
        "item1" => 'New Pixi Post', "quantity1" => 1, cnt: 1, qtyCnt: 1, "price1" => 5.00
  end

  def visit_free_txn_path
    visit new_transaction_path id: @listing.pixi_id, promo_code: '2013LAUNCH', title: @listing.title,
        "item1" => 'New Pixi Post', "quantity1" => 1, cnt: 1, qtyCnt: 1, "price1" => 5.00
  end

  def user_data
    fill_in 'first_name', with: @user.first_name
    fill_in 'last_name', with: @user.last_name
    fill_in 'transaction_email', with: @user.email
    fill_in 'transaction_home_phone', with: @user.contacts[0].home_phone
    fill_in 'transaction_address', with: @user.contacts[0].address
    fill_in 'transaction_city', with: @user.contacts[0].city
  end

  def user_data_with_state
    user_data
    select("California", :from => "transaction_state")
    fill_in 'transaction_zip', with: @user.contacts[0].zip
  end

  def invalid_card_dates
    select "January", from: "card_month"
    select (Date.today.year).to_s, from: "card_year"
  end

  def valid_card_dates
    select "January", from: "card_month"
    select (Date.today.year+1).to_s, from: "card_year"
  end

  def visa_card
    fill_in "card_number", with: "4242424242424242"
  end

  def no_card_data
    fill_in "card_number", with: ""
    fill_in "card_code",  with: "123"
    valid_card_dates
  end

  def visa_card_data
    visa_card
    fill_in "card_code",  with: "123"
    valid_card_dates
    click_valid_ok
  end

  def visa_card_data_bad_dates
    visa_card
    fill_in "card_code",  with: "123"
    invalid_card_dates
  end

  def visa_card_data_bad_cvv
    visa_card
    fill_in "card_code",  with: "12"
    valid_card_dates
  end

  def visa_card_data_no_cvv
    visa_card
    fill_in "card_code",  with: ""
    valid_card_dates
  end

  def visa_card_declined
    fill_in "card_number", with: "4000000000000002"
    fill_in "card_code",  with: "123"
    valid_card_dates
  end

  def visa_card_data_expired
    fill_in "card_number", with: "4000000000000069"
    fill_in "card_code",  with: "123"
    valid_card_dates
  end

  def visa_card_data_error
    fill_in "card_number", with: "4000000000000119"
    fill_in "card_code",  with: "123"
    valid_card_dates
  end

  def mc_card
    fill_in "card_number", with: "5555555555554444"
  end

  def mc_card_data
    mc_card
    fill_in "card_code",  with: "123"
    valid_card_dates
    click_valid_ok
  end

  def mc_card_data_bad_dates
    mc_card
    fill_in "card_code",  with: "123"
    invalid_card_dates
  end

  def mc_card_data_bad_cvv
    mc_card
    fill_in "card_code",  with: "12"
    valid_card_dates
  end

  def ax_card
    fill_in "card_number", with: "378282246310005"
  end

  def ax_card_data
    ax_card
    fill_in "card_code",  with: "123"
    valid_card_dates
    click_valid_ok
  end

  def ax_card_data_bad_dates
    ax_card
    fill_in "card_code",  with: "123"
    invalid_card_dates
  end

  def ax_card_data_bad_cvv
    ax_card
    fill_in "card_code",  with: "12"
    valid_card_dates
  end

  def discover_card
    fill_in "card_number", with: "6011000990139424"
  end

  def discover_card_data
    discover_card
    fill_in "card_code",  with: "123"
    valid_card_dates
    click_valid_ok
  end

  def discover_card_data_bad_dates
    discover_card
    fill_in "card_code",  with: "123"
    invalid_card_dates
  end

  def discover_card_data_bad_cvv
    discover_card
    fill_in "card_code",  with: "12"
    valid_card_dates
  end

  def diners_card
    fill_in "card_number", with: "6011000990139424"
  end

  def diners_card_data
    diners_card
    fill_in "card_code",  with: "123"
    valid_card_dates
    click_valid_ok
  end

  def diners_card_data_bad_dates
    diners_card
    fill_in "card_code",  with: "123"
    invalid_card_dates
  end

  def diners_card_data_bad_cvv
    diners_card
    fill_in "card_code",  with: "12"
    valid_card_dates
  end

  def jcb_card
    fill_in "card_number", with: "3530111333300000"
  end

  def jcb_card_data
    jcb_card
    fill_in "card_code",  with: "123"
    valid_card_dates
    click_valid_ok
  end

  def jcb_card_data_bad_dates
    jcb_card
    fill_in "card_code",  with: "123"
    invalid_card_dates
  end

  def jcb_card_data_bad_cvv
    jcb_card
    fill_in "card_code",  with: "12"
    valid_card_dates
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
    page.should have_content("your pixi will be posted")
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
      visit_free_txn_path 
    end

    it "Reviews a pixi" do
      expect { 
	      click_link '<< Prev Step: Review'
	}.not_to change(Transaction, :count)

      page.should have_content "Review Your Pixi" 
    end
  end

  describe "Manage Free Valid Transactions", :js=>true do
    before(:each) do 
      FactoryGirl.create :promo_code
      visit_free_txn_path 
    end

    it "should create a transaction with 100% discount" do
      user_data_with_state
      click_ok
      page.should have_content 'Order Complete'
    end

    it "Cancel transaction" do
      click_cancel_ok
      page.should have_content "Pixis" 
    end

    it "Cancel transaction cancel" do
      expect { 
        click_cancel_cancel
	}.not_to change(Transaction, :count)

      page.should have_content "Submit Your Order" 
    end

    it "Cancel transaction submission" do
      expect { 
	      click_submit_cancel
	}.not_to change(Transaction, :count)

      page.should have_content "Submit Your Order" 
    end
  end

  describe "Manage Valid Transactions", :js=>true do
    before(:each) do
      visit_txn_path 
      user_data_with_state
    end

    it "should create a transaction with valid visa card" do
      visa_card_data
    end

    it "should create a transaction with valid mc card" do
      mc_card_data
    end

    it "should create a transaction with valid ax card" do
      ax_card_data
    end

    it "should create a transaction with valid discover card" do
      discover_card_data
    end

    it "should create a transaction with valid diners card" do
      diners_card_data
    end

    it "should create a transaction with valid jcb card" do
      jcb_card_data
    end
  end

  describe "Manage Invalid Transactions", :js=>true do
    before { visit_txn_path }

    describe "Create with invalid address information" do
      it "should not create a transaction with invalid first name" do
        expect { 
          fill_in 'first_name', with: ""
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with invalid last name" do
        expect { 
          fill_in 'last_name', with: ""
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with blank home phone" do
        expect { 
          fill_in 'transaction_home_phone', with: ""
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end
    end

    describe "Create with invalid email information" do
      it "should not create a transaction with blank email" do
        expect { 
          fill_in 'transaction_email', with: ""
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with bad email" do
        expect { 
          fill_in 'transaction_email', with: "user@x."
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end
    end

    describe "Create with invalid address information" do
      it "should not create a transaction w/o address" do
        expect { 
          fill_in 'first_name', with: @user.first_name
          fill_in 'last_name', with: @user.last_name
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with no street address" do
        expect { 
	  user_data
          fill_in 'transaction_address', with: ""
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with no city" do
        expect { 
	  user_data
          fill_in 'transaction_city', with: ""
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with no state" do
        expect { 
	  user_data
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with no zip" do
        expect { 
	  user_data_with_state
          fill_in 'transaction_zip', with: ""
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end
    end

    describe "Create with invalid Visa card information" do
      before { user_data_with_state }

      it "should not create a transaction with no card #" do
        expect { 
	  no_card_data
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with no cvv" do
        expect { 
	  visa_card_data_no_cvv
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with expired card" do
        expect { 
	  visa_card_data_expired
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Order'
      end

      it "should not create a transaction with declined card" do
        expect { 
	  visa_card_declined
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Order'
      end

      it "should not create a transaction with bad_cvv card" do
        expect { 
	  visa_card_data_bad_cvv
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with bad_dates card" do
        expect { 
	  visa_card_data_bad_dates
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with error card" do
        expect { 
	  visa_card_data_error
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Order'
      end
    end

    describe "Create with invalid Mastercard information" do
      before { user_data_with_state }

      it "should not create a transaction with bad_cvv card" do
        expect { 
	  mc_card_data_bad_cvv
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with bad_dates card" do
        expect { 
	  mc_card_data_bad_dates
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end
    end

    describe "Create with invalid amex information" do
      before { user_data_with_state }

      it "should not create a transaction with bad_cvv card" do
        expect { 
	  ax_card_data_bad_cvv
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with bad_dates card" do
        expect { 
	  ax_card_data_bad_dates
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end
    end

    describe "Create with invalid Discover information" do
      before { user_data_with_state }

      it "should not create a transaction with bad_cvv card" do
        expect { 
	  discover_card_data_bad_cvv
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with bad_dates card" do
        expect { 
	  discover_card_data_bad_dates
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end
    end

    describe "Create with invalid Diners information" do
      before { user_data_with_state }

      it "should not create a transaction with bad_cvv card" do
        expect { 
	  diners_card_data_bad_cvv
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with bad_dates card" do
        expect { 
	  diners_card_data_bad_dates
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end
    end

    describe "Create with invalid JCB information" do
      before { user_data_with_state }

      it "should not create a transaction with bad_cvv card" do
        expect { 
	  jcb_card_data_bad_cvv
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with bad_dates card" do
        expect { 
	  jcb_card_data_bad_dates
	  click_ok }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end
    end
  end
end

