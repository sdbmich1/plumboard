require 'spec_helper'

describe InvoiceObserver do
  let(:user) { FactoryGirl.create(:pixi_user) }
  let(:buyer) { FactoryGirl.create(:pixi_user, first_name: 'Bob', last_name: 'Davis', email: 'bob.davis@pixitest.com') }
  let(:listing) { FactoryGirl.create(:listing, seller_id: user.id) }

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
    @observer.stub(:convenience_fee).with(@model).and_return(@txn)
    @account = mock(BankAccount)
    @observer = InvoiceObserver.instance
    @observer.stub(:credit_account).with(@model).and_return(@account)
  end

  describe 'after_update' do

    before(:each) do
      @account = user.bank_accounts.build FactoryGirl.attributes_for :bank_account
      @model = user.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: listing.pixi_id, buyer_id: buyer.id, 
        bank_account_id: @account.id) 
      @model.price, @model.status = 150.00, 'paid'
    end

    it 'should send a post' do
      process_post
    end

    it 'should mark as sold' do
      mark_pixi
    end

    it 'should credit account' do
      credit_account
      PixiPayment.stub(:add_transaction).with(@model, 0.99, 'abcdeg').and_return(true)
    end
  end

  describe 'after_create' do

    before do
      @model = user.invoices.build FactoryGirl.attributes_for(:invoice, pixi_id: listing.pixi_id, buyer_id: buyer.id) 
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
