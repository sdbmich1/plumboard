require 'spec_helper'

describe CardAccount do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user)
    @account = @user.card_accounts.build FactoryGirl.attributes_for :card_account
  end

  subject { @account }

  it { should respond_to(:user_id) }
  it { should respond_to(:card_no) }
  it { should respond_to(:card_number) }
  it { should respond_to(:card_type) }
  it { should respond_to(:status) }
  it { should respond_to(:token) }
  it { should respond_to(:description) }
  it { should respond_to(:expiration_month) }
  it { should respond_to(:expiration_year) }
  it { should respond_to(:zip) }
  it { should respond_to(:default_flg) }

  it { should respond_to(:user) }
  it { should respond_to(:set_flds) }

  it { should belong_to(:user) }
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:expiration_year) }
  it { should validate_presence_of(:expiration_month) }
  it { should validate_presence_of(:card_type) }
  it { should validate_presence_of(:zip) }
  it { should ensure_length_of(:zip).is_equal_to(5) }
  it { should allow_value(41572).for(:zip) }
  it { should_not allow_value(725).for(:zip) }
  
  describe "when user_id is empty" do
    before { @account.user_id = "" }
    it { should_not be_valid }
  end

  describe "when user_id is entered" do
    before { @account.user_id = 1 }
    it { @account.user_id.should == 1 }
  end
  
  describe "when expiration_month is empty" do
    before { @account.expiration_month = "" }
    it { should_not be_valid }
  end

  describe "when expiration_month is entered" do
    before { @account.expiration_month = 1 }
    it { @account.expiration_month.should == 1 }
  end
  
  describe "when expiration_year is empty" do
    before { @account.expiration_year = "" }
    it { should_not be_valid }
  end

  describe "when expiration_year is entered" do
    before { @account.expiration_year = 1 }
    it { @account.expiration_year.should == 1 }
  end
  
  describe "when card_type is empty" do
    before { @account.card_type = "" }
    it { should_not be_valid }
  end

  describe "when card_type is entered" do
    before { @account.card_type = "visa" }
    it { @account.card_type.should == "visa" }
  end

  describe 'must_have_token' do
    it 'has a token' do
      @account.valid?.should be_true
    end

    it 'has no token' do
      @account.token = nil
      @account.valid?.should_not be_true
    end
  end
  
  describe 'active' do
    it 'should be active' do
      @account.status = 'active'
      @account.save
      CardAccount.active.should be_true
    end

    it 'should not be active' do
      @account.status = 'pending'
      CardAccount.active.should be_empty
    end
  end

  describe 'save_account' do
    before do
      CardAccount.any_instance.stub(:save_account).and_return({user_id: 1, card_number: '4111111111111111', status: 'active', card_code: '123',
                  expiration_month: 6, expiration_year: 2019, zip: '94108'})
    end

    it 'saves account' do
      @account.save_account.should be_true
    end
  end

  describe 'save_account w/ bad data' do
    before do
      CardAccount.any_instance.stub(:save_account).and_return(false)
    end

    it 'does not save account' do
      @account.save_account.should_not be_true
    end
  end

  describe 'set_flds' do
    it "sets default flag" do
      account = @user.card_accounts.build FactoryGirl.attributes_for :card_account, status: nil
      account.save
      account.status.should == 'active'
      account.default_flg.should == 'Y'
    end

    it "does not set default flag" do
      @user.card_accounts.create FactoryGirl.attributes_for :card_account
      account = @user.card_accounts.build FactoryGirl.attributes_for :card_account, status: 'inactive'
      account.save
      account.status.should_not == 'active'
      account.default_flg.should_not == 'Y'
    end
  end

  describe 'has_expired?' do
    it 'does not return true' do
      @account.has_expired?.should_not be_true
    end

    it 'has past expiration year' do
      account = FactoryGirl.build :card_account, expiration_year: Date.today.year-1
      account.has_expired?.should be_true
    end

    it 'has past expiration month' do
      account = FactoryGirl.build :card_account, expiration_year: Date.today.year, expiration_month: Date.today.month-1
      account.has_expired?.should be_true
    end
  end

  describe 'add_card' do
    it 'has an existing token' do
      @txn = @user.transactions.build FactoryGirl.attributes_for(:transaction, card_number: '9000900090009000', exp_month: Date.today.month+1,
        exp_year: Date.today.year+1, cvv: '123', zip: '11111', payment_type: 'visa')
      CardAccount.add_card(@txn, @txn.token).should be_true
    end

    it 'has an existing card' do
      acct = @user.card_accounts.create FactoryGirl.attributes_for :card_account
      @txn = @user.transactions.build FactoryGirl.attributes_for(:transaction, card_number: '9000900090009000')
      CardAccount.add_card(@txn, @txn.token).should be_true
    end

    it 'has no card number' do
      @txn = @user.transactions.build FactoryGirl.attributes_for(:transaction, card_number: nil)
      CardAccount.add_card(@txn, @txn.token).should_not be_true
    end
  end

  describe 'delete_card' do
    before do
      @card_acct = mock('Balanced::Card')
      Balanced::Card.stub!(:find).with(@account.token).and_return(@card_acct)
      Balanced::Card.stub!(:unstore).and_return(true)
      @card_acct.stub!(:unstore).and_return(true)
    end

    it 'should delete account' do
      @account.save!
      @account.delete_card
      @account.errors.any?.should_not be_true
    end

    it 'should not delete account' do
      @account.token = nil
      @account.delete_card.should_not be_true
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
end
