require 'spec_helper'

describe CardAccount do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user)
    @account = @user.card_accounts.build FactoryGirl.attributes_for :card_account
  end

  subject { @account }

  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:card_no) }
  it { is_expected.to respond_to(:card_number) }
  it { is_expected.to respond_to(:card_type) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:token) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:expiration_month) }
  it { is_expected.to respond_to(:expiration_year) }
  it { is_expected.to respond_to(:zip) }
  it { is_expected.to respond_to(:default_flg) }
  it { is_expected.to respond_to(:card_token) }

  it { is_expected.to respond_to(:user) }
  it { is_expected.to respond_to(:set_flds) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:subscriptions) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:expiration_year) }
  it { is_expected.to validate_presence_of(:expiration_month) }
  it { is_expected.to validate_presence_of(:card_type) }
  it { is_expected.to validate_presence_of(:zip) }
  it { is_expected.to validate_length_of(:zip).is_equal_to(5) }
  it { is_expected.to allow_value(41572).for(:zip) }
  it { is_expected.not_to allow_value(725).for(:zip) }
  
  describe "when user_id is empty" do
    before { @account.user_id = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when user_id is entered" do
    before { @account.user_id = 1 }
    it { expect(@account.user_id).to eq(1) }
  end
  
  describe "when expiration_month is empty" do
    before { @account.expiration_month = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when expiration_month is entered" do
    before { @account.expiration_month = 1 }
    it { expect(@account.expiration_month).to eq(1) }
  end
  
  describe "when expiration_year is empty" do
    before { @account.expiration_year = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when expiration_year is entered" do
    before { @account.expiration_year = 1 }
    it { expect(@account.expiration_year).to eq(1) }
  end
  
  describe "when card_type is empty" do
    before { @account.card_type = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when card_type is entered" do
    before { @account.card_type = "visa" }
    it { expect(@account.card_type).to eq("visa") }
  end

  describe 'must_have_token' do
    it 'has a token' do
      expect(@account.valid?).to be_truthy
    end

    it 'has no token' do
      @account.token = nil
      expect(@account.valid?).not_to be_truthy
    end
  end
  
  describe 'active' do
    it 'should be active' do
      @account.status = 'active'
      @account.save
      expect(CardAccount.active).to be_truthy
    end

    it 'should not be active' do
      @account.status = 'pending'
      expect(CardAccount.active).to be_empty
    end
  end

  describe 'save_account' do
    context 'success' do
      before do
        allow_any_instance_of(CardAccount).to receive(:save_account).and_return({user_id: 1, card_number: '4111111111111111', status: 'active', card_code: '123',
                  expiration_month: 6, expiration_year: 2019, zip: '94108'})
      end
      it { expect(@account.save_account).to be_truthy }
    end

    context 'save_account w/ bad data' do
      before do
        allow_any_instance_of(CardAccount).to receive(:save_account).and_return(false)
      end
      it { expect(@account.save_account).not_to be_truthy }
    end
  end

  describe 'set_flds' do
    it "sets default flag" do
      account = @user.card_accounts.build FactoryGirl.attributes_for :card_account, status: nil
      account.save
      expect(account.status).to eq('active')
      expect(account.default_flg).to eq('Y')
    end

    it "does not set default flag" do
      @user.card_accounts.create FactoryGirl.attributes_for :card_account
      account = @user.card_accounts.build FactoryGirl.attributes_for :card_account, status: 'inactive'
      account.save
      expect(account.status).to eq('active')
      expect(account.default_flg).not_to eq('Y')
    end
  end

  describe 'has_expired?' do
    it 'does not return true' do
      expect(@account.has_expired?).not_to be_truthy
    end

    it 'has past expiration year' do
      account = FactoryGirl.build :card_account, expiration_year: Date.today.year-1
      expect(account.has_expired?).to be_truthy
    end

    it 'has past expiration month' do
      account = FactoryGirl.build :card_account, expiration_year: Date.today.year, expiration_month: Date.today.month-1
      expect(account.has_expired?).to be_truthy
    end
  end

  describe "remove cards", process: true do
    it { expect(CardAccount.remove_cards(@user)).to be_falsey }

    it "removes cards" do
      @account.save
      expect {
        CardAccount.remove_cards(@user)
      }.to change { CardAccount.count }.from(1).to(0)
    end
  end

  describe 'add_card', process: true do
    before :each, run: true do
      allow_any_instance_of(CardAccount).to receive(:save_account).and_return({user_id: 1, card_number: '4111111111111111', status: 'active', card_code: '123',
                  expiration_month: 6, expiration_year: 2019, zip: '94108'})
      @txn = @user.transactions.build FactoryGirl.attributes_for(:transaction, card_number: '4111111111111111', exp_month: Date.today.month+1,
        exp_year: Date.today.year+1, cvv: '123', zip: '11111', payment_type: 'visa')
    end

    it 'has an existing token', run: true do
      expect(CardAccount.add_card(@txn, @txn.token)).to be_truthy
    end

    it 'has an existing card', run: true do
      acct = @user.card_accounts.create FactoryGirl.attributes_for :card_account
      expect(CardAccount.add_card(@txn, @txn.token)).to be_truthy
    end

    it 'has no card number' do
      allow_any_instance_of(CardAccount).to receive(:save_account).and_return(false)
      @txn = @user.transactions.build FactoryGirl.attributes_for(:transaction, card_number: nil)
      expect(CardAccount.add_card(@txn, @txn.token)).not_to be_truthy
    end
  end

  describe 'delete_card' do
    before do
      @account.save!
      @card_acct = double('Stripe::Customer')
      allow(Stripe::Customer).to receive(:retrieve).with(@account.cust_token).and_return(@card_acct)
      allow(@card_acct).to receive_message_chain(:sources, :retrieve, :delete).and_return(true)
    #  Payment.should_receive(:delete_card).and_return(true)
    end

    it { expect(@account.delete_card).to be_truthy }

    it 'should delete account' do
      @account.delete_card
      expect(@account.reload.status).to eq 'removed'
    end

    it 'should not delete account' do
      @account.token = nil
      expect(@account.delete_card).not_to be_truthy
    end

    it 'resets default card' do
      @account2 = @user.card_accounts.create FactoryGirl.attributes_for :card_account, card_no: '5556'
      @account.delete_card
      expect(@account2.reload.default_flg).to eq 'Y'
    end
  end

  describe 'get_default_acct' do
    it 'returns acct' do
      @account.save
      expect(CardAccount.get_default_acct).not_to be_blank
    end

    it 'does not return acct' do
      expect(CardAccount.get_default_acct).to be_blank
    end

    it 'does not return acct' do
      @account.save
      @account2 = @user.card_accounts.create FactoryGirl.attributes_for :card_account, card_no: '5100'
      expect(CardAccount.get_default_acct.card_no).to eq '9000'
      expect(CardAccount.get_default_acct.card_no).not_to eq '5100'
    end
  end

  describe 'email' do
    it { expect(@account.email).to eq @user.email }
  end

  describe 'buyer_name' do
    it { expect(@account.buyer_name).to eq @user.name }
  end

  describe 'cust_token' do
    before :each, run: true do
      @user.update_attribute(:cust_token, 'XXX123')
    end
    it { expect(@account.cust_token).to be_nil }
    it 'has cust_token', run: true do
      expect(@account.cust_token).to eq @user.cust_token
    end
  end
  
  describe 'card acct list', list: true do
    it_behaves_like "account list methods", 'card_account', 'CardAccount', 'card_list'
  end

  describe 'toggle_default_flg' do
    it 'sets default_flg to nil' do
      @account.default_flg = 'Y'
      @account.save
      default_card = @user.card_accounts.create FactoryGirl.attributes_for(:card_account, default_flg: 'Y')
      expect(@account.reload.default_flg).to be_nil
      expect(default_card.reload.default_flg).to eq 'Y'
    end
  end
end
