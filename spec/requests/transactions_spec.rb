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

  def valid_card_dates
    select "January", from: "card_month"
    select (Date.today.year+1).to_s, from: "card_year"
  end

  def visa_card_data
    fill_in "card_number", with: "4242424242424242"
    fill_in "card_code",  with: "123"
    valid_card_dates
  end

  def visa_card_declined
    fill_in "card_number", with: "4000000000000002"
    fill_in "card_code",  with: "123"
    valid_card_dates
  end

  def paid_transaction
    @total = 15.0
  end

  def free_transaction
    @total = 0.0
  end

  describe "Manage Invalid Transactions" do
    before(:each) do
      visit new_transaction_path user_id: @user.id, id: @listing.id, promo_code: '', title: @listing.title,
        item1: 'New Pixi Post', quantity1: 1, cnt: 1, qtyCnt: 1, price: 5.00
    end

    describe "Create with invalid address information" do
      it "should not create a transaction with invalid first name" do
        expect { 
          fill_in 'first_name', with: ""
	  click_button submit }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with invalid last name" do
        expect { 
          fill_in 'last_name', with: ""
	  click_button submit }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with blank home phone" do
        expect { 
          fill_in 'transaction_home_phone', with: ""
	  click_button submit }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end
    end

    describe "Create with invalid email information" do
      it "should not create a transaction with blank email" do
        expect { 
          fill_in 'transaction_email', with: ""
	  click_button submit }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with bad email" do
        expect { 
          fill_in 'transaction_email', with: "user@x."
	  click_button submit }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end
    end

    describe "Create with invalid address information" do
      it "should not create a transaction w/o address" do
        expect { 
          fill_in 'first_name', with: @user.first_name
          fill_in 'last_name', with: @user.last_name
	  click_button submit }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with no street address" do
        expect { 
	  user_data
          fill_in 'transaction_address', with: ""
	  click_button submit }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with no city" do
        expect { 
	  user_data
          fill_in 'transaction_city', with: ""
	  click_button submit }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with no state" do
        expect { 
	  user_data
	  click_button submit }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end

      it "should not create a transaction with no zip" do
        expect { 
	  user_data_with_state
          fill_in 'transaction_zip', with: ""
	  click_button submit }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end
    end

    it "Reviews a pixi" do
      expect { 
	      click_link '<< Prev Step: Review'
	}.not_to change(Transaction, :count)

      page.should have_content "Review Your Pixi" 
    end

    describe "Create with invalid credit card information" do

      it "should not create a transaction with no card #" do
        save_and_open_page
        expect { 
	  user_data_with_state
	  visa_card_data
          fill_in 'card_number', with: ""
	  click_button submit }.not_to change(Transaction, :count)

        page.should have_content 'Submit Your Order'
      end
    end
  end

  describe "Manage Valid Transactions" do
    before(:each) do
      visit new_transaction_path user_id: @user.id, id: @listing.id, promo_code: '2013LAUNCH', title: @listing.title,
        item1: 'New Pixi Post', quantity1: 1, cnt: 1, qtyCnt: 1, price: 5.00
    end

    it "should create a transaction with no price" do
      expect { 
	  user_data_with_state
	  click_button submit }.to change(Transaction, :count).by(1)

      page.should have_content 'Confirmation'
    end
  end
end

