require 'spec_helper'

feature "CardAccounts" do
  subject { page }
  let(:user) { FactoryGirl.create(:pixi_user) }
  let(:submit) { "Save" }

  before(:each) do
    FactoryGirl.create :category
    FactoryGirl.create :category, name: 'Electronics'
    login_as(user, :scope => :user, :run_callbacks => false)
    @user = user
  end

  def invalid_card_dates
    select "January", from: "cc_card_month"
    select (Date.today.year).to_s, from: "cc_card_year"
  end

  def valid_card_dates
    select "January", from: "cc_card_month"
    select (Date.today.year+2).to_s, from: "cc_card_year"
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

  def balanced
    @api_key = Balanced::ApiKey.new.save
    Balanced.configure @api_key.secret
  end

  def set_token
    page.execute_script %Q{ $('#token').val("X98XX88X") }
  end

  def click_ok
    click_button submit 
    page.driver.browser.switch_to.alert.accept
  end

  def click_valid_ok
    click_button submit 
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

  def click_remove_ok
    click_link 'Remove'
    page.driver.browser.switch_to.alert.accept
  end
	                  
  def click_remove_cancel
    click_link 'Remove'
    page.driver.browser.switch_to.alert.dismiss
  end

  def submit_invalid_acct
    expect {
      click_on 'Save'; sleep 3;
    }.to change(CardAccount, :count).by(0)

    page.should have_content 'Card #'
    page.should have_content 'invalid'
  end

  describe "Create Card Account", js: true do 
    before do
      visit root_path
      click_link 'My Accounts'
      click_link 'Card'
    end

    it { should have_selector('h2', text: 'Setup Your Card Account') }
    it { should have_content("Card #") }
    it { should have_button("Save") }

    it "creates an new account" do
      expect {
        credit_card_data; sleep 2
      }.to change(CardAccount, :count).by(1)

      # page.should have_content 'Home'
      page.should have_link 'Remove'
      page.should have_content 'Card #'
      page.should have_content 'Default'
    end
  end

  describe "Delete Card Account", js: true do 
    before do
      @account = @user.card_accounts.create FactoryGirl.attributes_for :card_account, status: 'active'
      visit root_path
      click_link 'My Accounts'
      click_link 'Card'
    end

    it { should have_selector('h2', text: 'Your Card Account') }
    it { should have_content("Card #") }
    it { should have_link("Remove", href: card_account_path(@account)) }

    it "removes an account" do
      click_remove_cancel
      page.should have_link('Remove', href: card_account_path(@account)) 
      click_remove_ok
      page.should_not have_link("#{@account.id}", href: card_account_path(@account)) 
      page.should_not have_content 'Card #'
    end
  end

  describe "Invalid Card Account" do 
    before do
      visit root_path
      click_link 'My Accounts'
      click_link 'Card'
    end

    describe 'visit create page', js: true do
      it { should have_selector('h2', text: 'Setup Your Card Account') }
      it { should have_content("Card #") }
      it { should have_button("Save") }

      it "rejects missing card #" do
	credit_card_data '', '123', true
      end

      it "rejects invalid card number" do
	credit_card_data '0000', '123', true
      end

      it "rejects missing card code" do
	credit_card_data '4111111111111111', '', true
      end

      it "rejects invalid card code" do
	credit_card_data '4111111111111111', '10', true
      end

      it "rejects invalid exp date" do
	credit_card_data '4111111111111111', '123', false
      end
    end
  end
end
