require 'spec_helper'

describe Conversation do
    before(:each) do
      @user = FactoryGirl.create :pixi_user
      @recipient = FactoryGirl.create :pixi_user, first_name: 'Tom', last_name: 'Davis', email: 'tom.davis@pixitest.com'
      @buyer = FactoryGirl.create :pixi_user, first_name: 'Jack', last_name: 'Smith', email: 'jack.smith99@pixitest.com'
      @listing = FactoryGirl.create :listing, seller_id: @user.id, title: 'Big Guitar'
      @conversation = @listing.conversations.create FactoryGirl.attributes_for :conversation, user_id: @user.id, recipient_id: @recipient.id
      @post = @conversation.posts.create FactoryGirl.attributes_for :post, user_id: @user.id, recipient_id: @recipient.id, pixi_id: @listing.pixi_id
    end

    subject { @conversation }

    it { should respond_to(:user_id) }
    it { should respond_to(:pixi_id) }
    it { should respond_to(:recipient_id) }
    it { should respond_to(:user) }
    it { should respond_to(:listing) }
    it { should respond_to(:recipient) }
    it { should respond_to(:invoice) }
    it { should respond_to(:posts) }

    describe "when user_id is empty" do
      before { @conversation.user_id = "" }
      it { should_not be_valid }
    end

    describe "when user_id is not empty" do
      it { should be_valid }
    end

    describe "when pixi_id is empty" do
      before { @conversation.pixi_id = "" }
      it { should_not be_valid }
    end

    describe "when pixi_id is not empty" do
      it { should be_valid }
    end

    describe "when recipient_id is empty" do
      before { @conversation.recipient_id = "" }
      it { should_not be_valid }
    end

    describe "when recipient_id is not empty" do
      it { should be_valid}
    end

    describe "when accessing posts" do
      it "has first post" do
        expect(@conversation.posts.first).not_to be_nil
      end
    end
end
