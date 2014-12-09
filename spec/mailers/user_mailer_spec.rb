require "spec_helper"

describe UserMailer do

  describe "send_transaction_receipt" do
    subject { UserMailer.send_transaction_receipt(transaction)}
    let(:transaction) { create :transaction, status: 'approved' }

    it { expect{subject.deliver}.not_to change{ActionMailer::Base.deliveries.length}.by(0) }
    its(:to) { should == [transaction.email] }
    its(:subject) { should include "Your Purchase Receipt: #{transaction.confirmation_no} " }

    it 'assigns buyer first_name' do
      expect(subject.body.encoded).to match(transaction.first_name)
    end
  end

  describe "send_payment_receipt" do
    subject { UserMailer.send_payment_receipt(invoice, payment)}
    let(:seller) { create :pixi_user }
    let(:buyer) { create :pixi_user }
    let(:listing) { create :listing, seller_id: seller.id }
    let(:transaction) { create :transaction, status: 'approved' }
    let(:invoice) { create :invoice, status: 'paid', buyer_id: buyer.id, seller_id: seller.id, pixi_id: listing.pixi_id }
    let(:acct) {{"bank_account"=>{"account_number"=>"xxxxxx0001", "bank_name"=>"BANK OF AMERICA, N.A."}, "id"=>"BA3EKY6DoRFNhAoOzcb6xL5Y", "amount"=>10000}}
    let(:payment) { RecursiveOpenStruct.new acct }

    it { expect{subject.deliver}.not_to change{ActionMailer::Base.deliveries.length}.by(0) }
    its(:to) { should == [invoice.seller_email] }
    its(:subject) { should include "Your Payment Receipt: #{payment.id} " }

    it 'assigns buyer first_name' do
      expect(subject.body.encoded).to match(invoice.seller_first_name)
    end

    it 'assigns confirmation number' do
      expect(subject.body.encoded).to match(payment.id)
    end
  end

  describe "send_approval" do
    subject { UserMailer.send_approval(listing)}
    let(:user) { create :pixi_user }
    let(:listing) { create :listing, seller_id: user.id }

    it { expect{subject.deliver}.not_to change{ActionMailer::Base.deliveries.length}.by(0) }
    its(:to) { should == [listing.seller_email] }
    its(:subject) { should include "Pixi Approved: #{listing.title}" }

    it 'assigns seller_first_name' do
      expect(subject.body.encoded).to match(listing.seller_first_name)
    end

    it 'assigns message body' do
      expect(subject.body.encoded).to match("approved")
    end
  end

  describe "send_repost" do
    subject { UserMailer.send_approval(listing)}
    let(:user) { create :pixi_user }
    let(:listing) { FactoryGirl.create :listing, seller_id: user.id, repost_flg: true }

    it { expect{subject.deliver}.not_to change{ActionMailer::Base.deliveries.length}.by(0) }
    its(:to) { should == [listing.seller_email] }
    its(:subject) { should include "Pixi Reposted: #{listing.title}" }

    it 'assigns seller_first_name' do
      expect(subject.body.encoded).to match(listing.seller_first_name)
    end

    it 'assigns message body' do
      expect(subject.body.encoded).to match("reposted")
    end
  end

  describe "test_send_inquiry_notice" do
    subject { UserMailer.send_inquiry_notice(inquiry)}
    let (:inquiry) { FactoryGirl.create :inquiry}

    it { expect{subject.deliver}.not_to change{ActionMailer::Base.deliveries.length}.by(0) }
    its(:to) { should == ["support@pixiboard.com"] }
    its(:subject) { should include "[ TEST ]" }
  end

  describe "production_send_inquiry_notice" do
    before { Rails.stub_chain(:env, :production?) { true } }
    subject { UserMailer.send_inquiry_notice(inquiry)}
    let (:inquiry) { FactoryGirl.create :inquiry}

    it { expect{subject.deliver}.not_to change{ActionMailer::Base.deliveries.length}.by(0) }
    its(:to) { should == ["support@pixiboard.com"] }
    its(:subject) { should_not include "[ TEST ]" }
  end
end
