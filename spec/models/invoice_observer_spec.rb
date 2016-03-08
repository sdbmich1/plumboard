require 'spec_helper'

describe InvoiceObserver do
  before :all do
    @user = create(:pixi_user)
    @buyer = create(:pixi_user, first_name: 'Bob', last_name: 'Davis', email: 'bob.davis@pixitest.com')
    @listing = create(:listing, seller_id: @user.id)
  end

  def process_post
    @post = double(Post)
    @observer = InvoiceObserver.instance
    allow(@observer).to receive(:send_post).with(@model).and_return(@post)
  end

  def mark_pixi
    @listing = double(Listing)
    @observer = InvoiceObserver.instance
    allow(@observer).to receive(:mark_pixi).with(@model).and_return(@listing)
  end

  def credit_account
    @txn = double(Transaction)
    @observer = InvoiceObserver.instance
    allow(@observer).to receive(:transaction).with(@model).and_return(@txn)
    allow(@observer).to receive(:convenience_fee).with(@model).and_return(@txn)
    @account = double(BankAccount)
    @observer1 = InvoiceObserver.instance
    allow(@observer1).to receive(:bank_account).with(@model).and_return(@account)
    allow(@observer1).to receive(:credit_account).with(@model).and_return(@account)
  end

  def send_mailer
    @mailer = double(UserMailer)
    @observer = InvoiceObserver.instance
    allow(@observer).to receive(:delay).with(@mailer).and_return(@mailer)
    allow(@observer).to receive(:send_payment_receipt).with(@model).and_return(@mailer)
  end

  describe 'after_update' do
    let(:other_user) { create :pixi_user }

    before(:each) do
      @transaction = FactoryGirl.create :transaction, convenience_fee: 0.99
      @account = @user.bank_accounts.create FactoryGirl.attributes_for :bank_account
      @pixi_want = @user.pixi_wants.create FactoryGirl.attributes_for :pixi_want, pixi_id: @listing.pixi_id, status: 'active'
      @model = @user.invoices.build FactoryGirl.attributes_for(:invoice, buyer_id: @buyer.id, 
        bank_account_id: @account.id, transaction_id: @transaction.id ) 
      @details = @model.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: @listing.pixi_id, price: 150.00 
      @model.save!; sleep 5
      @model.status = 'paid'
    end

    it 'should send a post' do
      process_post
    end

    it 'should mark as sold' do
      mark_pixi
      allow(PixiWant).to receive(:set_status).with('1', @user.id, 'sold').and_return(true)
    end

    it 'should credit account' do
      credit_account
      allow(PixiPayment).to receive(:add_transaction).with(@model, 0.99, 'abcdeg').and_return(true)
    end

    it 'should deliver the receipt' do
      credit_account
      send_mailer
    end
  end

  describe 'after_update unpaid' do
    before do
      @model = @user.invoices.build FactoryGirl.attributes_for(:invoice, buyer_id: @buyer.id) 
      @details = @model.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: @listing.pixi_id, price: 150.00 
      @model.save!
    end

    it 'should send a post' do
      process_post
    end

    it 'should update shipping' do
      sleep 5
      @model.update_attribute(:ship_amt, 9.99)
      expect(@details.reload.fulfillment_type_code).to eq 'SHP'
    end
  end

  describe 'after_update decline' do
    before :all do
      @invoice = @user.invoices.build attributes_for(:invoice, buyer_id: @buyer.id, seller_id: @user.id, status: 'unpaid')
      @details = @invoice.invoice_details.build attributes_for(:invoice_detail, pixi_id: @listing.pixi_id)
      @buyer.pixi_wants.create attributes_for(:pixi_want, pixi_id: @listing.pixi_id)
      @listing.pictures.create attributes_for(:picture)
      @listing.conversations.create attributes_for :conversation, user_id: @user.id, recipient_id: @buyer.id
      @listing.conversations.first.posts.create attributes_for :post, user_id: @user.id, recipient_id: @buyer.id, pixi_id: @listing.pixi_id
      @invoice.save; sleep 5
    end

    it 'should send a post' do
      expect(Post).to receive(:add_post).and_return(double("Post"))
      @invoice.decline("No Longer Interested")
    end

    it 'should send decline email' do
      allow(UserMailer).to receive(:delay).and_return(UserMailer)
      expect(UserMailer).to receive(:send_decline_notice).and_return(double("UserMailer", :deliver => true))
      @invoice.decline("Incorrect Price")
    end

    it "removes wants" do
      pixi_want = double("PixiWant")
      allow(@invoice.buyer.pixi_wants).to receive(:find_by_pixi_id).with(@listing.pixi_id).and_return(pixi_want)
      expect(pixi_want).to receive(:destroy)
      @invoice.decline("Did Not Want")
    end
  end

  describe 'after_create' do

    before do
      @model = @user.invoices.build FactoryGirl.attributes_for(:invoice, buyer_id: @buyer.id) 
      @details = @model.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: @listing.pixi_id, price: 150.00 
    end

    it 'should send a post' do
      process_post
    end

    it 'should update shipping' do
      @model.ship_amt = 9.99
      @model.save!
      sleep 1
      expect(@details.reload.fulfillment_type_code).to eq 'SHP'
    end

    it 'should add inv pixi points' do
      @model.save!
      expect(@user.user_pixi_points.find_by_code('inv').code).to eq('inv')
    end

    it 'should send decline email' do
      allow(UserMailer).to receive(:delay).and_return(UserMailer)
      expect(UserMailer).to receive(:send_invoice_notice).and_return(double("UserMailer", :deliver => true))
      @model.save!
    end
  end
end
