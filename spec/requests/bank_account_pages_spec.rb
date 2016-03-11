require 'spec_helper'

feature "BankAccounts" do
  subject { page }
  let(:user) { FactoryGirl.create(:pixi_user, first_name: 'Jack', last_name: 'Snow', email: 'jack.snow@pixitest.com') }
  let(:submit) { "Save" }

  def change_data
    fill_in 'acct_number', with: '000123456789'
    fill_in 'bank_account_acct_name', with: "Personal Business"
  end

  def invalid_acct rte='110000000', acct='000111111113'
    fill_in 'routing_number', with: rte
    fill_in 'acct_number', with: acct
    fill_in 'bank_account_acct_name', with: "SDB Business"
    fill_in 'bank_account_description', with: "My business"
    select("checking", :from => "bank_account_acct_type")
  end

  def set_token
    page.execute_script %Q{ $('#token').val("X98XX88X") }
  end

  def submit_invalid_acct rte, acct
    expect {
      invalid_acct rte, acct
      click_on 'Next'; sleep 3;
    }.to change(BankAccount, :count).by(0)

    expect(page).not_to have_content 'Bill To'
    expect(page).to have_content 'Account #'
    expect(page).not_to have_content 'Successfully'
  end

  describe "Create Bank Account", create: true do 
    it_should_behave_like 'create_bank_account_page', 'pixi_user', 'not_to', 'to', false
    it_should_behave_like 'create_bank_account_page', 'business_user', 'to', 'not_to', false
    it_should_behave_like 'create_bank_account_page', 'business_user', 'not_to', 'to', true
  end

  describe "Delete Bank Account" do 
    before do
      px_user = create :pixi_user
      init_setup px_user
      @listing = FactoryGirl.create(:listing, seller_id: @user.id) 
      @account = @user.bank_accounts.create FactoryGirl.attributes_for :bank_account, status: 'active'
      visit root_path
      click_link 'My Accounts'
    end

    it "shows content" do
      expect(page).to have_content('Your Payment Account')
      expect(page).to have_content("Account #")
      expect(page).to have_link("Remove", href: bank_account_path(@account))
    end

    it "removes an account" do
    #  BankAccount.any_instance.stub(:delete_account).and_return(true)
      expect {
          click_on 'Remove'; sleep 3;
      }.to change(BankAccount, :count).by(0)

      # page.should_not have_content 'Pixis'
      expect(page).to have_content 'Account #'
    end
  end

  describe "Create Bank Account - Bill" do 
    before do
      px_user = create :pixi_user
      init_setup px_user
      @listing = FactoryGirl.create(:listing, seller_id: @user.id) 
      visit new_bank_account_path(target: 'shared/invoice_form')
      add_bank_data
    end

    it "shows content" do
      expect(page).to have_content('Setup Your Payment Account')
      expect(page).to have_content("You need to setup a bank account")
      expect(page).to have_content("Account #")
      expect(page).to have_button("Next")
    end

    it "creates an new account" do
      expect {
          click_on 'Next'; sleep 3;
      }.to change(BankAccount, :count).by(1)

      expect(page).to have_content 'My Invoices'
      expect(page).not_to have_content 'Account #'
    end
  end

  describe "Create Invoice Bank Account" do 
    before do
      px_user = create :pixi_user
      init_setup px_user
      @listing = FactoryGirl.create(:listing, seller_id: @user.id) 
    end

    describe 'visit create page' do
      before do
        visit new_bank_account_path(target: 'shared/invoice_form')
        add_bank_data
      end

      it "shows content" do
        expect(page).to have_content('Setup Your Payment Account')
        expect(page).to have_content("Account #")
        expect(page).to have_button("Next")
      end

      it "creates an new account" do
        expect {
            click_on 'Next'; sleep 3;
          }.to change(BankAccount, :count).by(1)
        expect(page).to have_content 'Bill To'
        expect(page).not_to have_content 'Account #'
      end

      it "attempts to create an invalid account" do
	submit_invalid_acct '110000000', '000'
	submit_invalid_acct '0000', '000111111113'
      end
    end
  end
end
