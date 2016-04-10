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

    expect(page).to have_content 'Card #'
    expect(page).to have_content 'invalid'
  end

  describe "Create Card Account", js: true do 
    before do
      visit new_bank_account_path
      click_link 'Card'; sleep 3
    end

    it 'shows content' do
      expect(page).to have_selector('h2', text: 'Setup Your Card Account')
      expect(page).not_to have_content("Card Holder")
      expect(page).to have_content("Card #")
      expect(page).to have_content("Default")
      expect(page).to have_button("Save")
    end

    it "creates an new account" do
      expect {
        load_credit_card "4242424242424242", "123", true, false; sleep 5
      }.to change(CardAccount, :count).by(1)
      expect(page).to have_content 'Card #'

      # page.should have_content 'Home'
      expect(page).to have_content 'Card #'

      visit new_card_account_path
      expect {
        load_credit_card "4242424242424242", "123", true, false; sleep 5
      }.to change(CardAccount, :count).by(0)
    end
  end

  describe 'Show Card Accounts', js: true do
    before do
      @account = @user.card_accounts.create attributes_for :card_account, status: 'active'
      visit new_bank_account_path
      click_link 'Card'
    end
    it "shows account" do
      expect(page).to have_content 'Card Holder'
      expect(page).to have_content 'Card #'
      expect(page).to have_content 'Default'
    end
  end

  describe "Delete Card Account", js: true do 
    before do
      @account = @user.card_accounts.create attributes_for :card_account, status: 'active'
      visit new_bank_account_path
      click_link 'Card'; sleep 2
      click_link 'Details'; sleep 2
    end

    it 'shows content' do
      expect(page).to have_selector('h2', text: 'Your Card Account')
      expect(page).to have_content("Card #")
      expect(page).to have_link("Remove") #, href: card_account_path(@account)
    end

    it "removes an account" do
      expect(page).to have_link("Remove") #, href: card_account_path(@account)
      click_remove_ok
      expect(page).not_to have_link("#{@account.id}", href: card_account_path(@account)) 
      expect(page).to have_link 'Add Card'
    end
  end

  describe "Invalid Card Account" do 
    before do
      allow_any_instance_of(CardAccount).to receive(:save_account).and_return(false)
      visit new_bank_account_path
      click_link 'Card'
    end

    describe 'visit create page' do
      it 'shows content' do
        expect(page).to have_content('Setup Your Card Account')
        expect(page).to have_content("Card #")
        expect(page).to have_button("Save")
      end

      it "rejects missing card #", js: true do
	credit_card_data nil, '123', true
        expect(page).not_to have_content('Successfully')

	credit_card_data '0000', '123', true
        expect(page).not_to have_content('Successfully')

	credit_card_data '4111111111111111', '  ', true
        expect(page).to have_content('Card declined')

	credit_card_data '4111111111111111', '123', false
        expect(page).to have_content('Card declined')

	credit_card_data '4111111111111111', '123', false, 99999
        expect(page).to have_content('Card declined')

	credit_card_data '4111111111111111', '123', false, ''
        expect(page).not_to have_content('Successfully')
      end
    end
  end
end
