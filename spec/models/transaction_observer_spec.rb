require 'spec_helper'

describe TransactionObserver do
  let(:user) { create(:contact_user) }

  def process_post
    @post = double(Post)
    @observer = TransactionObserver.instance
    allow(@observer).to receive(:send_post).with(@model).and_return(@post)
  end

  def update_addr model
    @user = double(User)
    @observer = TransactionObserver.instance
    allow(@observer).to receive(:update_contact_info).with(model).and_return(@user)
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
      expect(@txn.user.contacts[0].address).to eq(@txn.address) 
    end

    it 'should deliver the receipt' do
      @user_mailer = double(UserMailer)
      allow(UserMailer).to receive(:delay).and_return(UserMailer)
      expect(UserMailer).to receive(:send_transaction_receipt).with(@txn)
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
      expect(@model.user.contacts[0].address).to eq(@model.address) 
    end

    it 'should add inv pixi points' do
      @model.save!
      expect(user.user_pixi_points.find_by_code('inv').code).to eq('inv')
    end

    it 'should deliver the receipt' do
      @model.status = 'approved'
      @user_mailer = double(UserMailer)
      allow(UserMailer).to receive(:delay).and_return(UserMailer)
      expect(UserMailer).to receive(:send_transaction_receipt).with(@model)
      @model.save!
    end
  end
end
