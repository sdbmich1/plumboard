require 'spec_helper'

feature "CardAccounts" do
  subject { page }
  let(:user) { create(:contact_user) }
  let(:submit) { "Save" }

  before(:each) do
    create :category
    create :category, name: 'Electronics'
    init_setup user
  end

  def set_token
    page.execute_script %Q{ $('#token').val("X98XX88X") }
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
      visit new_bank_account_path
      click_link 'Card'
    end

    it 'shows content' do
      page.should have_selector('h2', text: 'Setup Your Card Account')
      page.should have_content("Card #")
      page.should have_button("Save")
    end

    it "creates an new account" do
      expect {
        load_credit_card "4242424242424242", "123", true, false; sleep 2.5
      }.to change(CardAccount, :count).by(1)
      page.should have_content 'Card #'

      # page.should have_content 'Home'
      page.should have_content 'Card #'
      page.should have_content 'Default'
    end
  end

  describe "Delete Card Account", js: true do 
    before do
      @account = @user.card_accounts.create attributes_for :card_account, status: 'active'
      visit new_bank_account_path
      click_link 'Card'
    end

    it 'shows content' do
      page.should have_selector('h2', text: 'Your Card Account')
      page.should have_content("Card #")
      page.should have_link("Remove", href: card_account_path(@account))
    end

    it "removes an account" do
      CardAccount.any_instance.stub(:delete_card).and_return(true)
      click_remove_cancel
      page.should have_link('Remove', href: card_account_path(@account)) 
      click_remove_ok
      page.should_not have_link("#{@account.id}", href: card_account_path(@account)) 
      page.should_not have_content 'Card #'
    end
  end

  describe "Invalid Card Account" do 
    before do
      CardAccount.any_instance.stub(:save_account).and_return(false)
      visit new_bank_account_path
      click_link 'Card'
    end

    describe 'visit create page' do
      it 'shows content' do
        page.should have_content('Setup Your Card Account')
        page.should have_content("Card #")
        page.should have_button("Save")
      end

      it "rejects missing card #", js: true do
	credit_card_data nil, '123', true
        page.should_not have_content('Successfully')

	credit_card_data '0000', '123', true
        page.should_not have_content('Successfully')

	credit_card_data '4111111111111111', '  ', true
        page.should have_content('Card declined')

	credit_card_data '4111111111111111', '123', false
        page.should have_content('Card declined')

	credit_card_data '4111111111111111', '123', false, 99999
        page.should have_content('Card declined')

	credit_card_data '4111111111111111', '123', false, ''
        page.should_not have_content('Successfully')
      end
    end
  end
end
