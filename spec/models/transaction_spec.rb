require 'spec_helper'

describe Transaction do
  before :all do
    @user = FactoryGirl.create :pixi_user
  end
  before(:each) do
    @transaction = @user.transactions.build FactoryGirl.attributes_for(:transaction)
  end

  subject { @transaction }

  describe 'txn attributes', base: true do
    it_behaves_like "model methods", %w(user listings transaction_details invoices pixi_payments)
    it_behaves_like 'an user', @transaction, :transaction
    it_behaves_like 'an address', @transaction, :transaction
    it { should respond_to(:payment_type) }
    it { should respond_to(:credit_card_no) }
    it { should respond_to(:description) }
    it { should respond_to(:amt) }
    it { should respond_to(:transaction_type) }
    it { should respond_to(:code) }
    it { should respond_to(:promo_code) }
    it { should respond_to(:user_id) }
    it { should respond_to(:cvv) }
    it { should respond_to(:confirmation_no) }
    it { should respond_to(:token) }
    it { should respond_to(:processing_fee) }
    it { should respond_to(:convenience_fee) }
    it { should respond_to(:debit_token) }
    it { should respond_to(:card_number) }
    it { should respond_to(:exp_month) }
    it { should respond_to(:exp_year) }
    it { should validate_presence_of(:home_phone) }
    it { should belong_to(:user) }
    it { should have_many(:transaction_details) }
    it { should have_many(:pixi_payments) }
    it { should have_many(:invoices) }
    it { should have_many(:listings).through(:invoices) }
    it { should_not allow_value('').for(:amt) }
    context 'amounts' do
      [['processing_fee', 1500], ['convenience_fee', 1500], ['amt', 15000]].each do |item|
        it { should validate_numericality_of(item[0].to_sym).is_greater_than_or_equal_to(0) }
        it_behaves_like 'an amount', item[0], item[1]
      end
    end
  end
  
  describe "load transaction" do
    let(:temp_listing) { create :temp_listing }
    let(:order) { {"cnt"=> 1, "item1"=> temp_listing.title, "id1"=> temp_listing.pixi_id, "quantity1"=> 1, "title"=> 'New Pixi', "price1"=> 5.0,
      "promo_code"=>''} }
    it "should load new transaction" do
      contact_user = create :contact_user 
      Transaction.load_new(contact_user, order).first_name.should_not be_nil
    end

    it "should not load new transaction" do
      Transaction.load_new(nil, order).first_name.should be_nil
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

    it "checks new item detail" do
      @transaction.add_details('pixi', 3, 10.99).should_not be_nil
      @transaction.save
      expect(TransactionDetail.last.price).to eq 10.99
    end

    it "should not load new item detail" do
      @transaction.add_details(nil, 0, 0).should be_nil
    end
  end

  describe "save transaction - pixi" do
    let(:temp_listing) { create :temp_listing }
    let(:order) { {"cnt"=> 1, "item1"=> temp_listing.title, "id1"=> temp_listing.pixi_id, "quantity1"=> 1, "title"=> 'New Pixi', "price1"=> 5.0,
      "promo_code"=>''} }

    it "should save order" do
      Transaction.any_instance.stub(:save_transaction).and_return(true)
      @transaction.save_transaction(order).should be_true
    end

    it "should not save order" do
      @transaction.first_name = nil
      @transaction.save_transaction(order).should_not be_true
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

  describe 'has_address?' do
    it 'should return true' do
      @transaction.has_address?.should be_true
    end

    it 'should not return true' do
      transaction = build :transaction, address: '', city: ''
      transaction.has_address?.should_not be_true
    end
  end

  describe 'has_token?' do
    it 'returns true' do
      @account = @user.card_accounts.create FactoryGirl.attributes_for :card_account
      expect(@transaction.has_token?).to be_true
    end

    it 'does not return true' do
      transaction = build :transaction, token: ''
      transaction.has_token?.should_not be_true
    end
  end

  describe 'valid_card?' do
    it 'should return true' do
      @transaction.card_number, @transaction.cvv = '4111111111111111', '123'
      @transaction.exp_month, @transaction.exp_year = 6, 2018
      @transaction.valid_card?.should be_true
    end

    it 'should not return true' do
      @transaction.valid_card?.should_not be_true
    end
  end

  describe 'pixi?' do
    it 'should return true' do
      @transaction.transaction_type = 'pixi'
      @transaction.pixi?.should be_true
    end

    it 'should not return true' do
      @transaction.transaction_type = 'invoice'
      @transaction.pixi?.should_not be_true
    end
  end

  describe 'get invoice' do
    before do
      @buyer = create(:pixi_user, first_name: 'Lucy', last_name: 'Smith', email: 'lucy.smith@lucy.com')
      @seller = create(:pixi_user, first_name: 'Lucy', last_name: 'Burns', email: 'lucy.burns@lucy.com') 
      @listing = create(:listing, seller_id: @user.id)
      @invoice = @seller.invoices.build FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @buyer.id)
      @details = @invoice.invoice_details.build attributes_for :invoice_detail, pixi_id: @listing.pixi_id 
    end

    it "does not get invoice pixi" do
      @transaction.get_invoice_listing.should_not be_true
      @transaction.get_invoice.should_not be_true
      @transaction.seller.should_not be_true
      @transaction.seller_name.should_not be_true
      @transaction.seller_id.should_not be_true
      @transaction.pixi_id.should_not be_true
      expect(@transaction.pixi_title).not_to eq @listing.title
    end

    it "gets invoice pixi" do
      @txn = @user.transactions.create FactoryGirl.attributes_for(:transaction, transaction_type: 'invoice')
      @invoice.transaction_id, @invoice.status = @txn.id, 'pending'
      @invoice.save!
      @invoice.transaction.get_invoice_listing.should be_true
      @invoice.transaction.get_invoice.should be_true
      @invoice.transaction.seller.should_not be_nil
      @invoice.transaction.seller_name.should == @seller.name
      @invoice.transaction.seller_id.should == @seller.id
      @invoice.transaction.pixi_id.should == @invoice.pixi_id
      @invoice.transaction.pixi_title.should == @listing.title
    end
  end

  describe "process transaction - Balanced" do
    before do
      set_payment_const('balanced')
      @customer = mock('Balanced::Customer')
      Balanced::Customer.stub_chain(:new, :save, :uri).and_return(@customer)
      @customer.stub!(:uri).and_return(true)
      @customer.stub!(:debit).with(amount: 10000, appears_on_statement_as: 'pixiboard.com', meta: {}).and_return(true)
    end

    it "does not process" do
      @transaction.first_name = nil
      @transaction.process_transaction.should_not be_true
    end

    it "processes txn" do
      Transaction.any_instance.stub(:process_transaction).and_return(true)
      @transaction.process_transaction.should be_true
    end
  end

  describe "save transaction - payment" do
    before do
      @buyer = create(:pixi_user, email: 'joedblow@pixitest.com') 
      @listing = create(:listing, seller_id: @user.id)
      @listing2 = create(:listing, seller_id: @user.id, title: 'Leather coat')
      @account = @user.bank_accounts.create FactoryGirl.attributes_for :bank_account
      @invoice = @user.invoices.build FactoryGirl.attributes_for(:invoice, buyer_id: @buyer.id, bank_account_id: @account.id)
      @details = @invoice.invoice_details.build attributes_for :invoice_detail, pixi_id: @listing.pixi_id 
      @details2 = @invoice.invoice_details.build attributes_for :invoice_detail, pixi_id: @listing2.pixi_id 
      @invoice.save!
      @order = {"title"=> 'Invoice #1', "invoice_id"=>@invoice.id, "cnt"=> 2, "seller"=> @invoice.seller_name, "qtyCnt"=>2,
        "quantity1"=> 2, "item1"=>@listing.title, "price1"=> 50.00, "id1"=>@listing.pixi_id,  
        "quantity2"=> 2, "item2"=>@listing2.title, "price2"=> 50.00, "id2"=>@listing2.pixi_id,  
        "inv_total"=>100.00, "transaction_type"=>'invoice', "promo_code"=>'' }
      @txn = @user.transactions.build FactoryGirl.attributes_for(:balanced_transaction, transaction_type: 'invoice')
    end

    it { should be_valid }

    it "should not save payment" do
      @txn.first_name = nil
      @txn.save_transaction(@order).should_not be_true
    end

    it "should save payment" do
      Transaction.any_instance.stub(:save_transaction).and_return(true)
      @txn.save_transaction(@order).should be_true
    end
  end

  describe 'get_fee' do
    it "should get fee" do 
      transaction = FactoryGirl.build :transaction, convenience_fee: 3.00, processing_fee: 0.99
      transaction.get_fee.should be_true
    end

    it "should not get fee" do 
      transaction = FactoryGirl.build :transaction, convenience_fee: '', processing_fee: ''
      expect(transaction.get_fee).to eq(0)
    end
  end

  describe 'has_amount?' do
    before do 
     @txn = FactoryGirl.build :transaction, amt: 50
    end

    it { expect(@txn.has_amount?).to eq(true) }

    it 'has no amount' do
      @txn.amt = 0
      expect(@txn.has_amount?).to eq(false) 
    end
  end

  describe 'txn_dt' do
    before :each do
      @buyer = create(:pixi_user, first_name: 'Lucy', last_name: 'Smith', email: 'lucy.smith@lucy.com')
      @seller = create(:pixi_user, first_name: 'Lucy', last_name: 'Burns', email: 'lucy.burns@lucy.com') 
      @listing = create(:listing, seller_id: @user.id)
      @invoice = @seller.invoices.build attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @buyer.id)
      @details = @invoice.invoice_details.build attributes_for :invoice_detail, pixi_id: @listing.pixi_id 
      @txn = @user.transactions.create attributes_for(:transaction, transaction_type: 'invoice')
      @invoice.transaction_id, @invoice.status = @txn.id, 'pending'
      @invoice.save!
    end

    it "show current created date" do
      expect(@txn.txn_dt).to eq @listing.display_date(@txn.created_at, true)
    end

    it "shows local created date" do
      @listing.lat, @listing.lng = 35.1498, -90.0492
      @listing.save
      expect(@txn.txn_dt).not_to eq @txn.created_at.strftime('%m/%d/%Y %l:%M %p')
    end
  end

  describe "get_by_date" do
    before :each do
      @txn = @user.transactions.create FactoryGirl.attributes_for(:transaction, transaction_type: 'invoice')
    end

    it "should get transactions in range" do
      Transaction.get_by_date(DateTime.current - 2.days, DateTime.current).should_not be_empty
      Transaction.get_by_date(DateTime.current - 2.days, DateTime.current + 1.days).should_not be_empty
    end

    it "should not get transactions out of range" do
      Transaction.get_by_date(DateTime.current - 2.days, DateTime.current - 1.days).should be_empty
    end
  end
end
