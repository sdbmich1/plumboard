require 'spec_helper'

describe CardAccount do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user, email: "jblow123@pixitest.com") 
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
      @card_acct = mock('Balanced::Card', uri: '', last_four: '0001', card_type: 'visa', expiration_month: 6, expiration_year: 2013)
      @card_acct.stub_chain(:new, :save).and_return(false)
      Balanced::Card.stub_chain(:new, :save).and_return(@card_acct)
    end

    it 'does not save account' do
      @account.save_account.should_not be_true
    end
  end

  describe 'add_card' do
  end
end
