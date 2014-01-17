require 'spec_helper'

describe BankAccount do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user, email: "jblow123@pixitest.com") 
    @account = @user.bank_accounts.build FactoryGirl.attributes_for :bank_account
  end

  subject { @account }

  it { should respond_to(:user_id) }
  it { should respond_to(:acct_name) }
  it { should respond_to(:bank_name) }
  it { should respond_to(:acct_no) }
  it { should respond_to(:acct_number) }
  it { should respond_to(:acct_type) }
  it { should respond_to(:status) }
  it { should respond_to(:token) }
  it { should respond_to(:description) }
  it { should respond_to(:default_flg) }

  it { should respond_to(:user) }
  it { should respond_to(:invoices) }
  it { should respond_to(:set_flds) }
  
  describe "when user_id is empty" do
    before { @account.user_id = "" }
    it { should_not be_valid }
  end

  describe "when user_id is entered" do
    before { @account.user_id = 1 }
    it { @account.user_id.should == 1 }
  end
  
  describe "when acct_name is empty" do
    before { @account.acct_name = "" }
    it { should_not be_valid }
  end

  describe "when acct_name is entered" do
    before { @account.acct_name = "temp checking" }
    it { @account.acct_name.should == "temp checking" }
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
      BankAccount.active.should be_true
    end

    it 'should not be active' do
      @account.status = 'pending'
      BankAccount.active.should be_empty
    end
  end

  describe 'get_account' do
    before do
      @bank_acct = mock('Balanced::BankAccount')
      Balanced::BankAccount.stub!(:find).with(@account.token).and_return(@bank_acct)
    end

    it 'should get account' do
      @account.get_account
      @account.errors.any?.should_not be_true
    end

    it 'should not get account' do
      @account.token = nil
      @account.get_account.should_not be_true
    end
  end

  describe 'save_account' do
    before do
      @bank_acct = mock('Balanced::BankAccount', uri: 'abcdef', account_number: 'xxx0001', bank_name: 'BofA')
      @bank_acct.stub_chain(:new, :save).and_return(true)
      @bank_acct.stub_chain(:uri, :account_number, :bank_name).and_return(@bank_acct)
      Balanced::BankAccount.stub_chain(:new, :save).and_return(@bank_acct)
      Balanced::BankAccount.stub_chain(:uri, :account_number, :bank_name).and_return(@bank_acct)
    end

    it 'should save account' do
      @account.save_account
      @account.errors.any?.should_not be_true
    end

    it 'should not save account' do
      @account.token = nil
      @account.save_account.should_not be_true
    end
  end

  describe 'credit_account' do
    before do
      @bank_acct = mock('Balanced::BankAccount', amount: '50000') 
      Balanced::BankAccount.stub!(:find).with(@account.token).and_return(@bank_acct)
      Balanced::BankAccount.stub!(:credit).with(:amount=>50000).and_return(@bank_acct)
      @bank_acct.stub!(:credit).with(:amount=>50000).and_return(true)
    end

    it 'should credit account' do
      @account.credit_account(500.00)
      @account.errors.any?.should_not be_true
    end

    it 'should not credit account' do
      @account.credit_account(0.00).should_not be_true
    end
  end

  describe 'delete_account' do
    before do
      @bank_acct = mock('Balanced::BankAccount')
      Balanced::BankAccount.stub!(:find).with(@account.token).and_return(@bank_acct)
      Balanced::BankAccount.stub!(:unstore).and_return(true)
      @bank_acct.stub!(:unstore).and_return(true)
    end

    it 'should delete account' do
      @account.save!
      @account.delete_account
      @account.errors.any?.should_not be_true
    end

    it 'should not delete account' do
      @account.token = nil
      @account.delete_account.should_not be_true
    end
  end
end
