require 'spec_helper'

feature "Transactions" do
  subject { page }
  let(:user) { FactoryGirl.create(:contact_user) }

  before(:each) do
    login_as(user, :scope => :user, :run_callbacks => false)
    user.confirm!
  end

  def user_data
    fill_in 'First Name', with: @user.first_name
    fill_in 'Last Name', with: @user.last_name
    fill_in 'Email', with: @user.email
    fill_in 'Address', with: @user.address
    fill_in 'City', with: @user.city
    select("CA", :from => "State")
    fill_in 'Zip', with: @user.zip
    fill_in 'Home Phone', with: @user.home_phone
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

  describe "Manage Invalid Transactions", :js => true do
    let(:submit) { "Done!" }
    before(:each) do
      FactoryGirl.create :state
      @user = user
      @listing = FactoryGirl.create :temp_listing, seller_id: @user.id
      visit build_transactions_path user_id: @user.id, id: @listing.id
    end

      wait_until do
      it "should not create a transaction with invalid user information" do
        expect { 
          fill_in 'transaction_first_name', with: ""
	  click_button submit }.not_to change(Transaction, :count)
      end
    end

    describe "Create with invalid email information" do
      it "should not create a transaction" do
        expect { 
	  user_data
          fill_in 'transaction_email', with: ""
	  click_button submit }.not_to change(Transaction, :count)
      end
    end

    describe "Create with no address information" do
      it "should not create a transaction" do
        expect { 
          fill_in 'First Name', with: @user.first_name
          fill_in 'Last Name', with: @user.last_name
	  click_button submit }.not_to change(Transaction, :count)
      end
    end
  end
end

