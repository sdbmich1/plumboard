require "spec_helper"

describe UserMailer do

  describe ".send_transaction_receipt" do
    subject { UserMailer.send_transaction_receipt(transaction)}
    let(:transaction) { FactoryGirl.create :transaction, status: 'approved' }

    it { expect{subject.deliver}.not_to change{ActionMailer::Base.deliveries.length}.by(0) }
    its(:to) { should == [transaction.email] }
    its(:subject) { should include "Your Purchase Receipt: " }
  end
end
