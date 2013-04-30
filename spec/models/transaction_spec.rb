require 'spec_helper'

describe Transaction do
  before(:each) do
    @user = FactoryGirl.create :pixi_user
    @transaction = @user.transactions.build FactoryGirl.attributes_for(:transaction)
  end

  subject { @transaction }

  it { should respond_to(:first_name) }
  it { should respond_to(:last_name) }
  it { should respond_to(:address) }
  it { should respond_to(:address2) }
  it { should respond_to(:email) }
  it { should respond_to(:home_phone) }
  it { should respond_to(:work_phone) }
  it { should respond_to(:city) }
  it { should respond_to(:state) }
  it { should respond_to(:zip) }
  it { should respond_to(:payment_type) }
  it { should respond_to(:country) }
  it { should respond_to(:credit_card_no) }
  it { should respond_to(:description) }
  it { should respond_to(:amt) }
  it { should respond_to(:code) }
  it { should respond_to(:promo_code) }
  it { should respond_to(:user_id) }
  it { should respond_to(:cvv) }
  it { should respond_to(:confirmation_no) }
  it { should respond_to(:token) }
  it { should respond_to(:processing_fee) }
  it { should respond_to(:convenience_fee) }

  it { should respond_to(:user) }
  it { should respond_to(:listings) }
  it { should respond_to(:transaction_details) }

  describe "when first_name is too long" do
    before { @transaction.first_name = "a" * 31 }
    it { should_not be_valid }
  end

  describe "when first_name is invalid" do
    before { @transaction.first_name = "@@@@" }
    it { should_not be_valid }
  end

  describe "when address is empty" do
    before { @transaction.address = "" }
    it { should_not be_valid }
  end

  describe "when last_name is too long" do
    before { @transaction.last_name = "a" * 31 }
    it { should_not be_valid }
  end

  describe "when last_name is invalid" do
    before { @transaction.last_name = "@@@@" }
    it { should_not be_valid }
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @transaction.email = invalid_address
        @transaction.should_not be_valid
      end      
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @transaction.email = valid_address
        @transaction.should be_valid
      end      
    end
  end

  describe "when address is too long" do
    before { @transaction.address = "@" * 51 }
    it { should_not be_valid }
  end

  describe "when city is invalid" do
    before { @transaction.city = "@@@@" }
    it { should_not be_valid }
  end

  describe "when city is too long" do
    before { @transaction.city = "@" * 51 }
    it { should_not be_valid }
  end

  describe "when city is empty" do
    before { @transaction.city = "" }
    it { should_not be_valid }
  end

  describe "when state is empty" do
    before { @transaction.state = "" }
    it { should_not be_valid }
  end

  describe "when zip is empty" do
    before { @transaction.zip = "" }
    it { should_not be_valid }
  end

  describe "when country is empty" do
    before { @transaction.country = "" }
    it { should_not be_valid }
  end

  describe "when home_phone is empty" do
    before { @transaction.home_phone = "" }
    it { should_not be_valid }
  end
 
  describe "when amt is empty" do
    before { @transaction.amt = "" }
    it { should_not be_valid }
  end

  describe "when amt is not a number" do
    before { @transaction.amt = "$500" }
    it { should_not be_valid }
  end
  
  describe "when amt is a number" do
    before { @transaction.amt = 50.00 }
    it { should be_valid }
  end
  
  describe "load transaction" do
    temp_listing = FactoryGirl.create :temp_listing 
    order = { promo_code: '',  "item1"=> 'New Pixi Post', "quantity1"=> 1, cnt: 1, qtyCnt: 1, "price1"=> 5.00}
    it "should load new transaction" do
      contact_user = FactoryGirl.create :contact_user 
      Transaction.load_new(contact_user, temp_listing, order).should_not be_nil
    end

    it "should not load new transaction" do
      Transaction.load_new(nil, temp_listing, order).should be_nil
    end
  end
  
  describe "refundable" do
    it "should be refundable" do
      @transaction.created_at = Time.now
      @transaction.refundable?.should be_true
    end

    it "should not be refundable" do
      @transaction.created_at = Time.now-6.months
      @transaction.refundable?.should_not be_true
    end
  end

  describe "load item detail" do
    it "should load new item detail" do
      @transaction.add_details('pixi', 1, 10.99).should_not be_nil
    end

    it "should not load new item detail" do
      @transaction.add_details(nil, 0, 0).should be_nil
    end
  end

  describe "save transaction" do
    let(:order) { {"cnt"=> 1, "quantity1"=> 1, "item1"=> 'Pixi Post', "price1"=> 0.0 } }
    let(:temp_listing) { FactoryGirl.create :temp_listing }

    it "should save" do
      @transaction.save_transaction(order, temp_listing).should be_true
    end

    it "should not save" do
      @transaction.first_name = nil
      @transaction.save_transaction(order, temp_listing).should_not be_true
    end
  end

  describe 'approved?' do
    it 'should return true' do
      @transaction.status = 'approved'
      @transaction.approved?.should be_true
    end

    it 'should not return true' do
      @transaction.status = 'pending'
      @transaction.approved?.should_not be_true
    end
  end

  describe "process transaction" do

    it "should not process" do
      @transaction.first_name = nil
      @transaction.process_transaction.should_not be_true
    end

    it "should process" do
      Stripe::Charge.should_receive(:create).and_raise(true)
      @transaction.save
      @transaction.process_transaction.should be_true
    end
  end
end
