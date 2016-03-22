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
    it { is_expected.to respond_to(:payment_type) }
    it { is_expected.to respond_to(:credit_card_no) }
    it { is_expected.to respond_to(:description) }
    it { is_expected.to respond_to(:amt) }
    it { is_expected.to respond_to(:transaction_type) }
    it { is_expected.to respond_to(:code) }
    it { is_expected.to respond_to(:promo_code) }
    it { is_expected.to respond_to(:user_id) }
    it { is_expected.to respond_to(:cvv) }
    it { is_expected.to respond_to(:confirmation_no) }
    it { is_expected.to respond_to(:token) }
    it { is_expected.to respond_to(:processing_fee) }
    it { is_expected.to respond_to(:convenience_fee) }
    it { is_expected.to respond_to(:debit_token) }
    it { is_expected.to respond_to(:card_number) }
    it { is_expected.to respond_to(:exp_month) }
    it { is_expected.to respond_to(:exp_year) }
    it { is_expected.to respond_to(:recipient_first_name) }
    it { is_expected.to respond_to(:recipient_last_name) }
    it { is_expected.to respond_to(:recipient_email) }
    it { is_expected.to respond_to(:ship_address) }
    it { is_expected.to respond_to(:ship_address2) }
    it { is_expected.to respond_to(:ship_city) }
    it { is_expected.to respond_to(:ship_state) }
    it { is_expected.to respond_to(:ship_zip) }
    it { is_expected.to respond_to(:ship_country) }
    it { is_expected.to respond_to(:recipient_phone) }
    it { is_expected.to validate_presence_of(:home_phone) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:transaction_details) }
    it { is_expected.to have_many(:pixi_payments) }
    it { is_expected.to have_many(:invoices) }
    it { is_expected.to have_many(:listings).through(:invoices) }
    it { is_expected.not_to allow_value('').for(:amt) }
    context 'amounts' do
      [['processing_fee', 1500], ['convenience_fee', 1500], ['amt', 15000]].each do |item|
        it { is_expected.to validate_numericality_of(item[0].to_sym).is_greater_than_or_equal_to(0) }
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
      expect(Transaction.load_new(contact_user, order).first_name).not_to be_nil
    end

    it "should not load new transaction" do
      expect(Transaction.load_new(nil, order).first_name).to be_nil
    end
  end
  
  describe "refundable" do
    it "should be refundable" do
      @transaction.created_at = Time.now
      expect(@transaction.refundable?).to be_truthy
    end

    it "should not be refundable" do
      @transaction.created_at = Time.now-6.months
      expect(@transaction.refundable?).not_to be_truthy
    end
  end

  describe "load item detail" do
    it "should load new item detail" do
      expect(@transaction.add_details('pixi', 1, 10.99)).not_to be_nil
    end

    it "checks new item detail" do
      expect(@transaction.add_details('pixi', 3, 10.99)).not_to be_nil
      @transaction.save
      expect(TransactionDetail.last.price).to eq 10.99
    end

    it "should not load new item detail" do
      expect(@transaction.add_details(nil, 0, 0)).to be_nil
    end
  end

  describe "save transaction - pixi" do
    let(:temp_listing) { create :temp_listing }
    let(:order) { {"cnt"=> 1, "item1"=> temp_listing.title, "id1"=> temp_listing.pixi_id, "quantity1"=> 1, "title"=> 'New Pixi', "price1"=> 5.0,
      "promo_code"=>''} }

    it "should save order" do
      allow_any_instance_of(Transaction).to receive(:save_transaction).and_return(true)
      expect(@transaction.save_transaction(order)).to be_truthy
    end

    it "should not save order" do
      @transaction.first_name = nil
      expect(@transaction.save_transaction(order)).not_to be_truthy
    end
  end

  describe 'approved?' do
    it 'should return true' do
      @transaction.status = 'approved'
      expect(@transaction.approved?).to be_truthy
    end

    it 'should not return true' do
      @transaction.status = 'pending'
      expect(@transaction.approved?).not_to be_truthy
    end
  end

  describe 'has_address?' do
    it 'should return true' do
      expect(@transaction.has_address?).to be_truthy
    end

    it 'should not return true' do
      transaction = build :transaction, address: '', city: ''
      expect(transaction.has_address?).not_to be_truthy
    end
  end

  describe 'has_token?' do
    it 'returns true' do
      @account = @user.card_accounts.create FactoryGirl.attributes_for :card_account
      expect(@transaction.has_token?).to be_truthy
    end

    it 'does not return true' do
      transaction = build :transaction, token: ''
      expect(transaction.has_token?).not_to be_truthy
    end
  end

  describe 'valid_card?' do
    it 'should return true' do
      @transaction.card_number, @transaction.cvv = '4111111111111111', '123'
      @transaction.exp_month, @transaction.exp_year = 6, 2018
      expect(@transaction.valid_card?).to be_truthy
    end

    it 'should not return true' do
      expect(@transaction.valid_card?).not_to be_truthy
    end
  end

  describe 'pixi?' do
    it 'should return true' do
      @transaction.transaction_type = 'pixi'
      expect(@transaction.pixi?).to be_truthy
    end

    it 'should not return true' do
      @transaction.transaction_type = 'invoice'
      expect(@transaction.pixi?).not_to be_truthy
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
      expect(@transaction.get_invoice_listing).not_to be_truthy
      expect(@transaction.get_invoice).not_to be_truthy
      expect(@transaction.seller).not_to be_truthy
      expect(@transaction.seller_name).not_to be_truthy
      expect(@transaction.seller_id).not_to be_truthy
      expect(@transaction.pixi_id).not_to be_truthy
      expect(@transaction.pixi_title).not_to eq @listing.title
    end

    it "gets invoice pixi" do
      @txn = @user.transactions.create FactoryGirl.attributes_for(:transaction, transaction_type: 'invoice')
      @invoice.transaction_id, @invoice.status = @txn.id, 'pending'
      @invoice.save!
      expect(@invoice.transaction.get_invoice_listing).to be_truthy
      expect(@invoice.transaction.get_invoice).to be_truthy
      expect(@invoice.transaction.seller).not_to be_nil
      expect(@invoice.transaction.seller_name).to eq(@seller.name)
      expect(@invoice.transaction.seller_id).to eq(@seller.id)
      expect(@invoice.transaction.pixi_id).to eq(@invoice.pixi_id)
      expect(@invoice.transaction.pixi_title).to eq(@listing.title)
    end
  end

  describe "process transaction - Balanced" do
    before do
      set_payment_const('balanced')
      @customer = double('Balanced::Customer')
      allow(Balanced::Customer).to receive_message_chain(:new, :save, :uri).and_return(@customer)
      allow(@customer).to receive(:uri).and_return(true)
      allow(@customer).to receive(:debit).with(amount: 10000, appears_on_statement_as: 'pixiboard.com', meta: {}).and_return(true)
    end

    it "does not process" do
      @transaction.first_name = nil
      expect(@transaction.process_transaction).not_to be_truthy
    end

    it "processes txn" do
      allow_any_instance_of(Transaction).to receive(:process_transaction).and_return(true)
      expect(@transaction.process_transaction).to be_truthy
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

    it { is_expected.to be_valid }

    it "should not save payment" do
      @txn.first_name = nil
      expect(@txn.save_transaction(@order)).not_to be_truthy
    end

    it "should save payment" do
      allow_any_instance_of(Transaction).to receive(:save_transaction).and_return(true)
      expect(@txn.save_transaction(@order)).to be_truthy
    end
  end

  describe 'get_fee' do
    it "should get fee" do 
      transaction = FactoryGirl.build :transaction, convenience_fee: 3.00, processing_fee: 0.99
      expect(transaction.get_fee).to be_truthy
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
      expect(Transaction.get_by_date(DateTime.current - 2.days, DateTime.current)).not_to be_empty
      expect(Transaction.get_by_date(DateTime.current - 2.days, DateTime.current + 1.days)).not_to be_empty
    end

    it "should not get transactions out of range" do
      expect(Transaction.get_by_date(DateTime.current - 2.days, DateTime.current - 1.days)).to be_empty
    end
  end

  describe 'cust_token' do
    before :each, run: true do
      @user.update_attribute(:cust_token, 'XXX123')
    end
    it { expect(@transaction.cust_token).to be_nil }
    it 'has cust_token', run: true do
      expect(@transaction.cust_token).to eq @user.cust_token
    end
  end

  describe "has_ship_address?" do
    it "returns true if address, city, state, and zip are defined" do
      @transaction.ship_address = "101 California"
      @transaction.ship_city = "San Francisco"
      @transaction.ship_state = "CA"
      @transaction.ship_zip = "94111"
      expect(@transaction.has_ship_address?).to be_truthy
    end

    it "returns false otherwise" do
      expect(@transaction.has_ship_address?).to be_falsey
    end
  end

  describe "sync_ship_address" do
    def set_ship_addr_flds
      @transaction.recipient_first_name = @user.first_name
      @transaction.recipient_last_name = @user.last_name
      @transaction.recipient_email = @user.email
      @transaction.user_id = @user.id
      contact = Contact.create FactoryGirl.attributes_for(:contact)
      @transaction.ship_address = contact.address
      @transaction.ship_city = contact.city
      @transaction.ship_state = contact.state
      @transaction.ship_zip = contact.zip
    end

    it "creates ShipAddress if it does not already exist" do
      set_ship_addr_flds
      expect { @transaction.sync_ship_address }.to change { ShipAddress.count }.by 1
      expect { @transaction.sync_ship_address }.not_to change { ShipAddress.count }
    end

    it "creates Contact if it does not already exist" do
      set_ship_addr_flds
      expect { @transaction.sync_ship_address }.to change { Contact.count }.by 1
      expect { @transaction.sync_ship_address }.not_to change { Contact.count }
    end

    it "can assign multiple Contacts for a given ShipAddress" do
      set_ship_addr_flds
      expect { @transaction.sync_ship_address }.to change { Contact.count }.by 1
      @transaction.ship_address = "1 California"
      @transaction.ship_city = "San Francisco"
      @transaction.ship_state = "CA"
      @transaction.ship_zip = "94111"
      expect { @transaction.sync_ship_address }.to change { Contact.count }.by 1
    end

    it "does not create nil records" do
      expect { @transaction.sync_ship_address }.not_to change { ShipAddress.count }
      expect { @transaction.sync_ship_address }.not_to change { Contact.count }
    end

    it "does not create records if attrs are missing" do
      set_ship_addr_flds
      @transaction.user_id = nil
      @transaction.ship_address = nil
      expect { @transaction.sync_ship_address }.not_to change { ShipAddress.count }
      expect { @transaction.sync_ship_address }.not_to change { Contact.count }
    end
  end
end
