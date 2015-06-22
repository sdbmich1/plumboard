require 'spec_helper'

describe BankAccount do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user)
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
  it { should respond_to(:currency_type_code) }
  it { should respond_to(:country_code) }

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
    context 'success' do
      before do
        BankAccount.any_instance.stub(:save_account).and_return({user_id: 1, acct_name: 'My Account', acct_no: '1234', bank_name: 'BoA',
                  status: 'active', token: 'xxx1234', acct_type: 'checking' })
      end
      it { expect(@account.save_account).to be_true }
    end

    context 'save_account w/ bad data' do
      before do
        BankAccount.any_instance.stub(:save_account).and_return(false)
      end
      it { expect(@account.save_account).not_to be_true }
    end
  end

  describe 'credit_account' do
    context 'success' do
      before do
        Payment.should_receive(:credit_account).and_return(true)
      end

      it 'should credit account' do
        @account.credit_account(500.00).should be_true
      end
    end

    context 'failure' do
      before do
        Payment.should_receive(:credit_account).and_return(false)
      end

      it 'should not credit account' do
        @account.credit_account(0.00).should_not be_true
      end
    end
  end

  describe 'delete_account' do
    context 'success' do
      before do
        Payment.should_receive(:delete_account).and_return(true)
      end

      it 'should delete account' do
        @account.save!
	@account.delete_account
	expect(@account.reload.status).to eq 'removed'
      end
    end

    context 'failure' do
      before do
        Payment.should_receive(:delete_account).and_return(false)
      end

      it 'should not delete account' do
        @account.save!
	@account.delete_account
        expect(@account.status).not_to eq 'removed'
      end
    end
  end

  describe "owner" do 
    it { expect(@account.owner_name).to eq(@user.name) } 
    it { expect(@account.owner_first_name).to eq(@user.first_name) } 
    it { expect(@account.email).to eq(@user.email) } 

    it "should not find correct owner name" do 
      @account.user_id = 100 
      @account.owner_first_name.should be_nil 
      @account.owner_name.should be_nil 
      @account.email.should be_nil 
    end
  end

  describe 'get_default_acct' do
    it 'returns acct' do
      @account.save
      expect(BankAccount.get_default_acct).not_to be_blank
    end

    it 'does not return acct' do
      expect(BankAccount.get_default_acct).to be_blank
    end

    it 'does not return acct' do
      @account.save
      @account2 = @user.bank_accounts.create FactoryGirl.attributes_for :bank_account, acct_no: '9002'
      expect(BankAccount.get_default_acct.acct_no).to eq @account.acct_no
      expect(BankAccount.get_default_acct.acct_no).not_to eq '9002'
    end
  end

  describe 'acct_token' do
    before :each, run: true do
      @user.update_attribute(:acct_token, 'XXX123')
    end
    it { expect(@account.acct_token).to be_nil }
    it 'has acct_token', run: true do
      expect(@account.acct_token).to eq @user.acct_token
    end
  end
end
