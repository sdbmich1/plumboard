require 'spec_helper'

feature "BankAccounts" do
  subject { page }
  let(:user) { FactoryGirl.create(:pixi_user, first_name: 'Jack', last_name: 'Snow', email: 'jack.snow@pixitest.com') }

  before(:each) do
    login_as(user, :scope => :user, :run_callbacks => false)
    @user = user
  end

  def add_data
    fill_in 'routing_number', with: '021000021'
    fill_in 'acct_number', with: 9900000002
    fill_in 'bank_account_acct_name', with: "SDB Business"
    fill_in 'bank_account_description', with: "My business"
    select("checking", :from => "bank_account_acct_type")
  end

  def balanced
    @api_key = Balanced::ApiKey.new.save
    Balanced.configure @api_key.secret
  end

  def invalid_acct
    fill_in 'routing_number', with: '100000007'
    fill_in 'acct_number', with: 8887776665555
    fill_in 'bank_account_acct_name', with: "SDB Business"
    fill_in 'bank_account_description', with: "My business"
    select("checking", :from => "bank_account_acct_type")
  end

  def set_token
    page.execute_script %Q{ $('#token').val("X98XX88X") }
  end

  def submit_invalid_acct
    expect {
      click_on 'Next'; sleep 3;
    }.to change(BankAccount, :count).by(0)

    page.should_not have_content 'Bill To'
    page.should have_content 'Account #'
  end

  describe "Create Bank Account" do 
    before do
      @listing = FactoryGirl.create(:listing, seller_id: @user.id) 
      visit invoices_path 
    end

    it { should have_link('Create', href: new_bank_account_path(target: 'shared/invoice_form')) }
    it { should_not have_link('Create', href: new_invoice_path) }

    describe 'visit create page', js: true do
      before do
        click_link 'Create'
        add_data
      end

      it { should have_selector('h2', text: 'Setup Your Payment Account') }
      it { should have_content("Account #") }
      it { should have_button("Next") }

      it "creates an new account" do
        expect {
            click_on 'Next'; sleep 3;
          }.to change(BankAccount, :count).by(1)

        page.should have_content 'Bill To'
        page.should_not have_content 'Account #'
      end

      it "rejects missing acct name" do
        fill_in 'bank_account_acct_name', with: ""
	submit_invalid_acct
      end

      it "rejects missing acct #" do
        fill_in 'acct_number', with: ""
	submit_invalid_acct
      end

      it "rejects missing routing #" do
        fill_in 'routing_number', with: ""
	submit_invalid_acct
      end

      it "rejects invalid routing #" do
        fill_in 'routing_number', with: "100000007"
	submit_invalid_acct
      end
    end
  end
end
