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
    let(:invoice) { build :invoice, status: 'paid', buyer_id: buyer.id, seller_id: seller.id }
    let(:acct) {{"bank_account"=>{"account_number"=>"xxxxxx0001", "bank_name"=>"BANK OF AMERICA, N.A."}, "id"=>"BA3EKY6DoRFNhAoOzcb6xL5Y", "amount"=>10000}}
    let(:payment) { RecursiveOpenStruct.new acct }
    before :each do
      invoice.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: listing.pixi_id 
      invoice.save!
    end

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

  describe "send_interest" do
    subject { UserMailer.send_interest(want)}
    let(:user) { create :pixi_user }
    let(:buyer) { create :pixi_user }
    let(:listing) { create :listing, seller_id: user.id }
    let(:want) { buyer.pixi_wants.create FactoryGirl.attributes_for :pixi_want, pixi_id: listing.pixi_id }

    it { expect{subject.deliver}.not_to change{ActionMailer::Base.deliveries.length}.by(0) }
    its(:to) { should == [listing.seller_email] }
    its(:subject) { should include "Pixiboard Post: Someone Wants Your #{listing.title}" }

    it 'assigns seller_first_name' do
      expect(subject.body.encoded).to match(listing.seller_first_name)
    end
  end

  describe "send_pixipost_request" do
    subject { UserMailer.send_pixipost_request(post)}
    let(:user) { create :pixi_user }
    let(:post) { user.pixi_posts.create FactoryGirl.attributes_for(:pixi_post) }

    it { expect{subject.deliver}.not_to change{ActionMailer::Base.deliveries.length}.by(0) }
    its(:to) { should == [post.seller_email] }
    its(:subject) { should include "PixiPost Request Submitted" }

    it 'assigns seller_first_name' do
      expect(subject.body.encoded).to match(post.seller_first_name)
    end
  end

  describe "send_pixipost_appt" do
    subject { UserMailer.send_pixipost_appt(post)}
    let(:user) { create :pixi_user }
    let(:post) { user.pixi_posts.create FactoryGirl.attributes_for(:pixi_post) }

    it { expect{subject.deliver}.not_to change{ActionMailer::Base.deliveries.length}.by(0) }
    its(:to) { should == [post.seller_email] }
    its(:subject) { should include "PixiPost Appointment Scheduled" }

    it 'assigns seller_first_name' do
      expect(subject.body.encoded).to match(post.seller_first_name)
    end
  end

  describe "send_pixipost_request_internal" do
    subject { UserMailer.send_pixipost_request_internal(post)}
    let(:user) { create :pixi_user }
    let(:post) { user.pixi_posts.create FactoryGirl.attributes_for(:pixi_post) }

    it { expect{subject.deliver}.not_to change{ActionMailer::Base.deliveries.length}.by(0) }
    its(:to) { should include "support@pixiboard.com" }
    its(:subject) { should include "PixiPost Request Submitted" }

    it 'assigns seller_name' do
      expect(subject.body.encoded).to match(post.seller_name)
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

  describe "ask_question" do
    subject { UserMailer.ask_question(@pixi_ask) }
    before do
      @user = FactoryGirl.create(:pixi_user) 
      @category = FactoryGirl.create(:category, pixi_type: 'premium') 
      @listing = FactoryGirl.create(:listing, seller_id: @user.id) 
      @pixi_ask = FactoryGirl.create(:pixi_ask, pixi_id: @listing.pixi_id)
    end
    it { expect{subject.deliver}.not_to change{ActionMailer::Base.deliveries.length}.by(0) }
    its(:to) { should == [@listing.seller_email] }
    its(:subject) {should include "Pixiboard Ask: Someone Has a Question About Your"}
  end

  describe "send_invoiceless_pixi_notice" do
    subject { UserMailer.send_invoiceless_pixi_notice(listing)}
    let(:user) { create :pixi_user }
    let(:listing) { create :listing, seller_id: user.id }

    it { expect{subject.deliver}.not_to change{ActionMailer::Base.deliveries.length}.by(0) }
    its(:to) { should == [listing.seller_email] }
    its(:subject) { should include "Reminder: Someone Wants Your #{listing.title}" }

    it 'assigns seller_first_name' do
      expect(subject.body.encoded).to match(listing.seller_first_name)
    end
  end

  describe "send_decline_notice" do
    subject { UserMailer.send_decline_notice(invoice, message)}
    let(:message) { "I am no longer interested in this pixi.  Thank you." }
    let(:seller) { create :pixi_user, email: "test@gmail.com" }
    let(:buyer) { create :pixi_user }
    let(:invoice) { build :invoice, status: 'declined', buyer_id: buyer.id, seller_id: seller.id, id: 1 }

    it { expect{subject.deliver}.not_to change{ActionMailer::Base.deliveries.length}.by(0) }
    its(:to) { should == [invoice.seller_email] }
    its(:subject) { should include "Invoice Declined" }

    it 'assigns seller_first_name' do
      expect(subject.body.encoded).to match(invoice.seller_first_name)
    end

    it 'sends message' do
      expect(subject.body.encoded).to match(message)
    end
  end

  describe "send_unpaid_old_invoice_notice" do
    subject { UserMailer.send_unpaid_old_invoice_notice(invoice)}
    let(:seller) { create :pixi_user }
    let(:buyer) { create :pixi_user }
    let(:invoice) { build :invoice, status: 'unpaid', buyer_id: buyer.id, seller_id: seller.id, id: 1 }

    it { expect{subject.deliver}.not_to change{ActionMailer::Base.deliveries.length}.by(0) }
    its(:to) { should == [invoice.buyer_email] }
    its(:subject) { should include "Reminder: Pixiboard Post: #{invoice.pixi_title}" }

    it 'assigns seller_first_name' do
      expect(subject.body.encoded).to match(invoice.buyer_first_name)
    end
  end
end
