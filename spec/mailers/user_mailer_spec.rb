require "spec_helper"

describe UserMailer do

  describe "send_transaction_receipt" do
    subject { UserMailer.send_transaction_receipt(transaction)}
    let(:transaction) { FactoryGirl.create :transaction, status: 'approved' }

    it { expect{subject.deliver}.not_to change{ActionMailer::Base.deliveries.length}.by(0) }
    its(:to) { should == [transaction.email] }
    its(:subject) { should include "Your Purchase Receipt: " }
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

end
