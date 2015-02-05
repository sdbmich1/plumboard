require 'spec_helper'

describe TransactionObserver do
  let(:user) { create(:contact_user) }

  def process_post
    @post = mock(Post)
    @observer = TransactionObserver.instance
    @observer.stub(:send_post).with(@model).and_return(@post)
  end

  def update_addr model
    @user = mock(User)
    @observer = TransactionObserver.instance
    @observer.stub(:update_contact_info).with(model).and_return(@user)
  end

  describe 'after_update' do
    before(:each) do
      @txn = create :transaction, address: '1234 Main Street', user_id: user.id 
      @txn.address = '3456 Elm'
      @txn.status = 'approved'
    end

    it 'updates contact info' do
      @txn.save!
      update_addr @txn
      @txn.user.contacts[0].address.should == @txn.address 
    end

    it 'should deliver the receipt' do
      @user_mailer = mock(UserMailer)
      UserMailer.stub(:delay).and_return(UserMailer)
      UserMailer.should_receive(:send_transaction_receipt).with(@txn)
      @txn.save!
    end
  end

  describe 'after_create' do
    before do
      @model = user.transactions.build FactoryGirl.attributes_for(:transaction, transaction_type: 'invoice', address: '1234 Main Street')
    end

    it 'sends a post' do
      process_post
    end

    it 'updates contact info' do
      @model.save!
      update_addr @model
      @model.user.contacts[0].address.should == @model.address 
    end

    it 'should add inv pixi points' do
      @model.save!
      user.user_pixi_points.find_by_code('inv').code.should == 'inv'
    end

    it 'should deliver the receipt' do
      @model.status = 'approved'
      @user_mailer = mock(UserMailer)
      UserMailer.stub(:delay).and_return(UserMailer)
      UserMailer.should_receive(:send_transaction_receipt).with(@model)
      @model.save!
    end
  end
end
