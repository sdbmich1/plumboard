require "spec_helper"

describe UserMailer do

  describe "send_transaction_receipt" do
    subject { UserMailer.send_transaction_receipt(transaction)}
    let(:transaction) { create :transaction, status: 'approved', confirmation_no: '1' }

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq([transaction.email]) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "Your Purchase Receipt: #{transaction.confirmation_no} " }
    end

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

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq([invoice.seller_email]) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "Your Payment Receipt: #{payment.id} " }
    end

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

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq([listing.seller_email]) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "Pixi Approved: #{listing.title}" }
    end

    it 'assigns seller_first_name' do
      expect(subject.body.encoded).to match(listing.seller_first_name)
    end

    it 'assigns message body' do
      expect(subject.body.encoded).to match("approved")
    end

    it 'assigns user_url' do
      expect(subject.body.encoded).to match(listing.seller_url)
    end
  end

  describe "send_repost" do
    subject { UserMailer.send_approval(listing)}
    let(:user) { create :pixi_user }
    let(:listing) { FactoryGirl.create :listing, seller_id: user.id, repost_flg: true }

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq([listing.seller_email]) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "Pixi Reposted: #{listing.title}" }
    end

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

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq([listing.seller_email]) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "Pixiboard Post: Someone Wants Your #{listing.title}" }
    end

    it 'assigns seller_first_name' do
      expect(subject.body.encoded).to match(listing.seller_first_name)
    end
  end

  describe "send_pixipost_request" do
    subject { UserMailer.send_pixipost_request(post)}
    let(:user) { create :pixi_user }
    let(:post) { user.pixi_posts.create FactoryGirl.attributes_for(:pixi_post) }

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq([post.seller_email]) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "PixiPost Request Submitted" }
    end

    it 'assigns seller_first_name' do
      expect(subject.body.encoded).to match(post.seller_first_name)
    end
  end

  describe "send_pixipost_appt" do
    subject { UserMailer.send_pixipost_appt(post)}
    let(:user) { create :pixi_user }
    let(:post) { user.pixi_posts.create FactoryGirl.attributes_for(:pixi_post) }

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq([post.seller_email]) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "PixiPost Appointment Scheduled" }
    end

    it 'assigns seller_first_name' do
      expect(subject.body.encoded).to match(post.seller_first_name)
    end
  end

  describe "send_pixipost_request_internal" do
    subject { UserMailer.send_pixipost_request_internal(post)}
    let(:user) { create :pixi_user }
    let(:post) { user.pixi_posts.create FactoryGirl.attributes_for(:pixi_post) }

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to include "support@pixiboard.com" }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "PixiPost Request Submitted" }
    end

    it 'assigns seller_name' do
      expect(subject.body.encoded).to match(post.seller_name)
    end
  end

  describe "test_send_inquiry_notice" do
    subject { UserMailer.send_inquiry_notice(inquiry)}
    let (:inquiry) { FactoryGirl.create :inquiry}

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq(["support@pixiboard.com"]) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "[ TEST ]" }
    end
  end

  describe "production_send_inquiry_notice" do
    before { allow(Rails).to receive_message_chain(:env, :production?) { true } }
    subject { UserMailer.send_inquiry_notice(inquiry)}
    let (:inquiry) { FactoryGirl.create :inquiry}

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq(["support@pixiboard.com"]) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.not_to include "[ TEST ]" }
    end
  end

  describe "ask_question" do
    subject { UserMailer.ask_question(@pixi_ask) }
    before do
      @user = FactoryGirl.create(:pixi_user) 
      @category = FactoryGirl.create(:category, pixi_type: 'premium') 
      @listing = FactoryGirl.create(:listing, seller_id: @user.id) 
      @pixi_ask = FactoryGirl.create(:pixi_ask, pixi_id: @listing.pixi_id)
    end
    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq([@listing.seller_email]) }
    end

    describe '#subject' do
      subject { super().subject }
      it {is_expected.to include "Pixiboard Ask: Someone Has a Question About Your"}
    end
  end

  describe "send_invoiceless_pixi_notice" do
    subject { UserMailer.send_invoiceless_pixi_notice(listing)}
    let(:user) { create :pixi_user }
    let(:listing) { create :listing, seller_id: user.id }

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq([listing.seller_email]) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "Reminder: Someone Wants Your #{listing.title}" }
    end

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

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq([invoice.seller_email]) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "Invoice Declined" }
    end

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

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq([invoice.buyer_email]) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "Reminder: Pixiboard Post: #{invoice.pixi_title}" }
    end

    it 'assigns seller_first_name' do
      expect(subject.body.encoded).to match(invoice.buyer_first_name)
    end
  end

  describe "send_expiring_pixi_notice" do
    subject { UserMailer.send_expiring_pixi_notice(7, user) }
    let(:user) { create :pixi_user }

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq([user.email]) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "Your Pixis are Expiring Soon!" }
    end

    it 'assigns user first_name' do
      expect(subject.body.encoded).to match(user.first_name)
    end
  end

  describe "send_invoice_notice" do
    subject { UserMailer.send_invoice_notice(invoice)}
    let(:seller) { create :pixi_user }
    let(:buyer) { create :pixi_user }
    let(:listing) { create :listing, seller_id: seller.id, title: "Test" }
    let(:invoice) { build :invoice, status: 'unpaid', buyer_id: buyer.id, seller_id: seller.id, id: 1 }
    before :each do
      invoice.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: listing.pixi_id 
      invoice.save!
    end

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq([invoice.buyer_email]) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "PixiPay Invoice ##{invoice.id} from #{invoice.seller_name}" }
    end

    it 'assigns buyer_first_name' do
      expect(subject.body.encoded).to match(invoice.buyer_first_name)
    end

    it 'assigns id' do
      expect(subject.body.encoded).to match(invoice.id.to_s)
    end

    it 'assigns seller_name' do
      expect(subject.body.encoded).to match(invoice.seller_name)
    end

    it 'assigns amount' do
      expect(subject.body.encoded).to match(invoice.amount.to_s)
    end

    it 'assigns pixi_title if the invoice is only for one listing' do
      expect(subject.body.encoded).to match(invoice.pixi_title)
    end

    it 'assigns "multiple pixis" if the invoice is for more than one listing' do
      listing2 = create :listing, seller_id: seller.id, title: "Test 2"
      invoice.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: listing2.pixi_id 
      invoice.save!
      multiple_listing_email = UserMailer.send_invoice_notice(invoice)
      expect(multiple_listing_email.body.encoded).to match("multiple pixis")
    end
  end

  describe "send_charge_failed" do
    subject { UserMailer.send_charge_failed(user)}
    let(:user) { create :pixi_user }

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq([user.email]) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "Charge Failed" }
    end

    it 'assigns user first name' do
      expect(subject.body.encoded).to match(user.first_name)
    end
  end

  describe "send_charge_dispute_created" do
    subject { UserMailer.send_charge_dispute_created(user)}
    let(:user) { create :pixi_user }

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq([user.email, 'support@pixiboard.com']) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "Charge Disputed" }
    end

    it 'assigns user first name' do
      expect(subject.body.encoded).to match(user.first_name)
    end
  end

  describe "send_charge_dispute_updated" do
    subject { UserMailer.send_charge_dispute_updated(user)}
    let(:user) { create :pixi_user }

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq([user.email, 'support@pixiboard.com']) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "Charge Disputed – Update" }
    end

    it 'assigns user first name' do
      expect(subject.body.encoded).to match(user.first_name)
    end
  end

  describe "send_charge_dispute_closed" do
    subject { UserMailer.send_charge_dispute_closed(user)}
    let(:user) { create :pixi_user }

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq([user.email, 'support@pixiboard.com']) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "Charge Dispute Closed" }
    end

    it 'assigns user first name' do
      expect(subject.body.encoded).to match(user.first_name)
    end
  end

  describe "send_customer_subscription_created" do
    subject { UserMailer.send_customer_subscription_created(user)}
    let(:user) { create :pixi_user }

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq([user.email]) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "First Payment Received – Thank You" }
    end

    it 'assigns user first name' do
      expect(subject.body.encoded).to match(user.first_name)
    end
  end

  describe "send_customer_subscription_trial_will_end" do
    subject { UserMailer.send_customer_subscription_trial_will_end(user)}
    let(:user) { create :pixi_user }

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq([user.email]) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "Your Subscription Trial Will End Soon" }
    end

    it 'assigns user first name' do
      expect(subject.body.encoded).to match(user.first_name)
    end
  end

  describe "send_customer_subscription_updated" do
    subject { UserMailer.send_customer_subscription_updated(user)}
    let(:user) { create :pixi_user }

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq([user.email]) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "Payment Received – Thank You" }
    end

    it 'assigns user first name' do
      expect(subject.body.encoded).to match(user.first_name)
    end
  end

  describe "send_customer_subscription_deleted" do
    subject { UserMailer.send_customer_subscription_deleted(user)}
    let(:user) { create :pixi_user }

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq([user.email, 'support@pixiboard.com']) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "Your Subscription Has Been Cancelled" }
    end

    it 'assigns user first name' do
      expect(subject.body.encoded).to match(user.first_name)
    end
  end

  describe "send_customer_updated" do
    subject { UserMailer.send_customer_updated(user)}
    let(:user) { create :pixi_user }

    it { expect{subject.deliver_now}.to change{ActionMailer::Base.deliveries.length} }

    describe '#to' do
      subject { super().to }
      it { is_expected.to eq([user.email]) }
    end

    describe '#subject' do
      subject { super().subject }
      it { is_expected.to include "Your Payment Information Has Been Updated" }
    end

    it 'assigns user first name' do
      expect(subject.body.encoded).to match(user.first_name)
    end
  end
end
