require 'spec_helper'

describe InvoiceObserver do
  let(:user) { create(:pixi_user) }
  let(:buyer) { create(:pixi_user, first_name: 'Bob', last_name: 'Davis', email: 'bob.davis@pixitest.com') }
  let(:listing) { create(:listing, seller_id: user.id) }

  def process_post
    @post = mock(Post)
    @observer = InvoiceObserver.instance
    @observer.stub(:send_post).with(@model).and_return(@post)
  end

  def mark_pixi
    @listing = mock(Listing)
    @observer = InvoiceObserver.instance
    @observer.stub(:mark_pixi).with(@model).and_return(@listing)
  end

  def credit_account
    @txn = mock(Transaction)
    @observer = InvoiceObserver.instance
    @observer.stub(:transaction).with(@model).and_return(@txn)
    @observer.stub(:convenience_fee).with(@model).and_return(@txn)
    @account = mock(BankAccount)
    @observer1 = InvoiceObserver.instance
    @observer1.stub(:bank_account).with(@model).and_return(@account)
    @observer1.stub(:credit_account).with(@model).and_return(@account)
  end

  def send_mailer
    @mailer = mock(UserMailer)
    @observer = InvoiceObserver.instance
    @observer.stub(:delay).with(@mailer).and_return(@mailer)
    @observer.stub(:send_payment_receipt).with(@model).and_return(@mailer)
  end

  describe 'after_update' do
    let(:other_user) { create :pixi_user }

    before(:each) do
      @transaction = FactoryGirl.create :transaction, convenience_fee: 0.99
      @account = user.bank_accounts.create FactoryGirl.attributes_for :bank_account
      @pixi_want = user.pixi_wants.create FactoryGirl.attributes_for :pixi_want, pixi_id: listing.pixi_id, status: 'active'
      @model = user.invoices.build FactoryGirl.attributes_for(:invoice, buyer_id: buyer.id, 
        bank_account_id: @account.id, transaction_id: @transaction.id ) 
      @details = @model.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: listing.pixi_id, price: 150.00 
      @model.save!; sleep 3
      @model.status = 'paid'
    end

    it 'should send a post' do
      process_post
    end

    it 'should mark as sold' do
      mark_pixi
      PixiWant.stub(:set_status).with(listing.pixi_id, user.id, 'sold').and_return(true)
    end

    it 'should credit account' do
      credit_account
      PixiPayment.stub(:add_transaction).with(@model, 0.99, 'abcdeg').and_return(true)
    end

    it 'should deliver the receipt' do
      credit_account
      send_mailer
    end
  end

  describe 'after_create' do

    before do
      @model = user.invoices.build FactoryGirl.attributes_for(:invoice, buyer_id: buyer.id) 
      @details = @model.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: listing.pixi_id, price: 150.00 
    end

    it 'should send a post' do
      process_post
    end

    it 'should add inv pixi points' do
      @model.save!
      user.user_pixi_points.find_by_code('inv').code.should == 'inv'
    end
  end
end
