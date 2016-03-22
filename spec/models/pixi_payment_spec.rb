require 'spec_helper'

describe PixiPayment do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user, email: "jblow12345@pixitest.com") 
    @buyer = FactoryGirl.create(:pixi_user, first_name: 'Jaine', last_name: 'Smith', email: 'jaine.smith@pixitest.com') 
    @listing = FactoryGirl.create(:listing, seller_id: @user.id)
    @account = @user.bank_accounts.create FactoryGirl.attributes_for :bank_account
    @txn = @user.transactions.create FactoryGirl.attributes_for(:balanced_transaction)
    @invoice = @user.invoices.build FactoryGirl.attributes_for(:invoice, buyer_id: @buyer.id, transaction_id: @txn.id, status: 'paid')
    @details = @invoice.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: @listing.pixi_id 
    @invoice.save!
    @payment = @invoice.pixi_payments.build FactoryGirl.attributes_for(:pixi_payment, buyer_id: @buyer.id,
      transaction_id: @txn.id, seller_id: @user.id, amount: @invoice.amount)
  end

  subject { @payment }

  it { is_expected.to respond_to(:pixi_id) }
  it { is_expected.to respond_to(:buyer_id) }
  it { is_expected.to respond_to(:seller_id) }
  it { is_expected.to respond_to(:transaction_id) }
  it { is_expected.to respond_to(:invoice_id) }
  it { is_expected.to respond_to(:pixi_fee) }
  it { is_expected.to respond_to(:amount) }
  it { is_expected.to respond_to(:token) }
  it { is_expected.to respond_to(:confirmation_no) }

  it { is_expected.to respond_to(:seller) }
  it { is_expected.to respond_to(:buyer) }
  it { is_expected.to respond_to(:transaction) }
  it { is_expected.to respond_to(:invoice) }
  
  it { is_expected.to be_valid }

  describe "when seller_id is empty" do
    before { @payment.seller_id = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when seller_id is entered" do
    before { @payment.seller_id = 1 }
    it { expect(@payment.seller_id).to eq(1) }
  end
  
  describe "when buyer_id is empty" do
    before { @payment.buyer_id = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when buyer_id is entered" do
    before { @payment.buyer_id = 1 }
    it { expect(@payment.buyer_id).to eq(1) }
  end
  
  describe "when invoice_id is empty" do
    before { @payment.invoice_id = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when invoice_id is entered" do
    it { expect(@payment.invoice_id).to eq(@invoice.id) }
  end
  
  describe "when transaction_id is empty" do
    before { @payment.transaction_id = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when transaction_id is entered" do
    before { @payment.transaction_id = 1 }
    it { expect(@payment.transaction_id).to eq(1) }
  end
  
  describe "when pixi_fee is a number" do
    before { @payment.pixi_fee = 50.00 }
    it { expect(@payment.pixi_fee).to eq(50.00) }
  end
  
  describe "when pixi_fee is empty" do
    before { @payment.pixi_fee = "" }
    it { is_expected.not_to be_valid }
  end
  
  describe "when amount is a number" do
    before { @payment.amount = 50.00 }
    it { is_expected.to be_valid }
  end
  
  describe "when amount is empty" do
    before { @payment.amount = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when token is not a number" do
    before { @payment.token = "xx00" }
    it { is_expected.to be_valid }
  end
  
  describe "when token is empty" do
    before { @payment.token = "" }
    it { is_expected.not_to be_valid }
  end
  
  describe 'add_transaction' do
    it { expect(PixiPayment.add_transaction(@invoice, 0.99, @txn.token, @txn.confirmation_no)).to be_truthy }
    it { expect(PixiPayment.add_transaction(@invoice, 0.99, nil, nil)).not_to be_truthy }
  end
end
