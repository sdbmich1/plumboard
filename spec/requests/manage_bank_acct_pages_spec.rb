require 'spec_helper'

feature "BankAccounts" do
  subject { page }
  let(:user) { create(:contact_user) }
  let(:user2) { create(:contact_user) }
  let(:admin) { create(:admin) }
  let(:submit) { "Save" }

  before(:each) do
    create :currency_type
    create :category, name: 'Electronics'
    init_setup admin
  end

  def set_token
    page.execute_script %Q{ $('#token').val("X98XX88X") }
  end

  describe "Create Bank Account - Admin", create: true do 
    before :each do
      visit new_bank_account_path(adminFlg: true)
    end

    it 'shows content' do
      expect(page).to have_content 'Manage Accounts'
      expect(page).to have_selector('h2', text: 'Setup Your Payment Account')
      expect(page).to have_content("Acct Holder")
      expect(page).to have_content("Account #")
      expect(page).to have_button("Save")
    end

    it "creates an new account", js: true do
      @other = create :contact_user, last_name: 'Bling'
      fill_autocomplete "slr_name", with: @other.name
      expect {
        add_bank_data
        click_on 'Save'; sleep 5;
      }.to change(BankAccount, :count).by(1)
      expect(page).to have_content 'Manage Accounts'
      expect(page).to have_content '# Accts'
      expect(page).to have_content @other.name
    end
  end

  describe 'Show Bank Accounts - Admin', process: true do
    before do
      @account = user.bank_accounts.create attributes_for :bank_account, acct_no: '9002'
      @account2 = user2.bank_accounts.create attributes_for :bank_account, acct_no: '9001', token: 'xxxx1234'
      sleep 5
      visit bank_accounts_path(adminFlg: true)
    end
    it "shows accounts" do
      expect(page).to have_content 'Manage Accounts'
      expect(page).to have_content 'User'
      expect(page).to have_content 'Email'
      expect(page).to have_content '# Accts'
      expect(page).to have_content user.name
      expect(page).to have_content user2.name
    end

    context 'delete bank', js: true do
      before do
        click_link 'Details'; sleep 2
        click_link 'Details'; sleep 2
      end

      it "removes an account" do
        expect(page).to have_link("Remove") #, href: bank_account_path(@account)
        click_remove_ok
        expect(page).not_to have_link("#{@account.id}", href: bank_account_path(@account)) 
        expect(page).to have_content 'Manage Accounts'
        expect(page).to have_content 'User'
        expect(page).to have_link 'Add Account'
        expect(page).not_to have_content user.name
        expect(page).to have_content user2.name
      end
    end
  end
end
