require 'spec_helper'

describe TransactionObserver do

  describe 'after_update' do
    let(:transaction) { FactoryGirl.create :transaction }
    before(:each) do
      transaction.status = 'approved'
    end

    it 'should deliver the receipt' do
      @user_mailer = mock(UserMailer)
      @user_mailer.should_receive(:deliver)
      UserMailer.stub(:send_transaction_receipt).with(transaction).and_return(@user_mailer)
      transaction.save!
    end
  end
end
