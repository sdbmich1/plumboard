require 'spec_helper'

describe BankAccount do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user)
    @account = @user.bank_accounts.build FactoryGirl.attributes_for :bank_account
  end

  subject { @account }

  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:acct_name) }
  it { is_expected.to respond_to(:bank_name) }
  it { is_expected.to respond_to(:acct_no) }
  it { is_expected.to respond_to(:acct_number) }
  it { is_expected.to respond_to(:acct_type) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:token) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:default_flg) }
  it { is_expected.to respond_to(:currency_type_code) }
  it { is_expected.to respond_to(:country_code) }

  it { is_expected.to respond_to(:user) }
  it { is_expected.to respond_to(:invoices) }
  it { is_expected.to respond_to(:set_flds) }
  
  describe "when user_id is empty" do
    before { @account.user_id = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when user_id is entered" do
    before { @account.user_id = 1 }
    it { expect(@account.user_id).to eq(1) }
  end
  
  describe "when acct_name is empty" do
    before { @account.acct_name = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when acct_name is entered" do
    before { @account.acct_name = "temp checking" }
    it { expect(@account.acct_name).to eq("temp checking") }
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
      expect(BankAccount.active).to be_truthy
    end

    it 'should not be active' do
      @account.status = 'pending'
      expect(BankAccount.active).to be_empty
    end
  end

  describe 'get_account' do
    before do
      @bank_acct = double('Balanced::BankAccount')
      allow(Balanced::BankAccount).to receive(:find).with(@account.token).and_return(@bank_acct)
    end

    it 'should get account' do
      @account.get_account
      expect(@account.errors.any?).not_to be_truthy
    end

    it 'should not get account' do
      @account.token = nil
      expect(@account.get_account).not_to be_truthy
    end
  end

  describe 'save_account' do
    context 'success' do
      before do
        allow_any_instance_of(BankAccount).to receive(:save_account).and_return({user_id: 1, acct_name: 'My Account', acct_no: '1234', bank_name: 'BoA',
                  status: 'active', token: 'xxx1234', acct_type: 'checking' })
      end
      it { expect(@account.save_account).to be_truthy }
    end

    context 'save_account w/ bad data' do
      before do
        allow_any_instance_of(BankAccount).to receive(:save_account).and_return(false)
      end
      it { expect(@account.save_account).not_to be_truthy }
    end
  end

  describe 'credit_account' do
    context 'success' do
      before do
        expect(Payment).to receive(:credit_account).and_return(true)
      end

      it 'should credit account' do
        expect(@account.credit_account(500.00)).to be_truthy
      end
    end

    context 'failure' do
      before do
        expect(Payment).to receive(:credit_account).and_return(false)
      end

      it 'should not credit account' do
        expect(@account.credit_account(0.00)).not_to be_truthy
      end
    end
  end

  describe 'delete_account' do
    context 'success' do
      before do
        # Payment.should_receive(:delete_account).and_return(true)
      end

      it 'should delete account' do
        @account.save!
	@account.delete_account
	expect(@account.reload.status).to eq 'removed'
      end
    end
  end

  describe "owner" do 
    it { expect(@account.owner_name).to eq(@user.name) } 
    it { expect(@account.owner_first_name).to eq(@user.first_name) } 
    it { expect(@account.email).to eq(@user.email) } 

    it "should not find correct owner name" do 
      @account.user_id = 100
      @account.save
      @account.reload
      expect(@account.owner_first_name).to be_nil 
      expect(@account.owner_name).to be_nil 
      expect(@account.email).to be_nil 
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
  
  describe 'bank acct list', list: true do
    it_behaves_like "account list methods", 'bank_account', 'BankAccount', 'acct_list'
  end
end
