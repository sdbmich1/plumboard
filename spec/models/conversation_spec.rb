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

    describe "removing posts" do
      before(:each) do
        @post = @conversation.posts.create FactoryGirl.attributes_for :post, user_id: @recipient.id, recipient_id: @user.id, pixi_id: @listing.pixi_id
      end

      it "removes all associated posts for right user" do
        @conversation.remove_posts(@user)
        @conversation.posts.each do |post|
          if post.user_id == @user.id
            expect(post.status).to eql('removed')
          end
        end
      end

      it "does not remove all associated posts for wrong user" do
        @conversation.remove_posts(@user)
        @conversation.posts.each do |post|
          if post.user_id != @user.id
            expect(post.status).to eql('active')
          end
        end
      end
    end

    describe "removing conversations" do
      context "removing user's conversation" do

        it "returns true if successful" do
          @result = Conversation.remove_conv(@conversation, @user)
          expect(@result).to eql(true)
        end

        it "returns false if unsuccessful" do
          @conversation.stub(:update_attributes).and_return(false)
          @result = Conversation.remove_conv(@conversation, @user)
          expect(@result).to eql(false)
        end

        it "sets user's status to removed" do
          @result = Conversation.remove_conv(@conversation, @user)
          expect(@conversation.status).to eql('removed')
        end

        it "does not set recipient_status to be removed" do
          @result = Conversation.remove_conv(@conversation, @user)
          expect(@conversation.recipient_status).to eql("active")
        end

        it "sets user's posts to removed" do
          @result = Conversation.remove_conv(@conversation, @user)
          @conversation.posts.each do |post|
            if post.user_id == @user.id
              expect(post.status).to eql('removed')
            end
          end
        end

        it "does not set other user's posts to removed" do
          @result = Conversation.remove_conv(@conversation, @user)
          @conversation.posts.each do |post|
            if post.user_id != @user.id
              expect(post.status).to eql('active')
            end
          end
        end
      end

      context "removing recipient's conversation" do

        it "returns true if successful" do
          @result = Conversation.remove_conv(@conversation, @recipient)
          expect(@result).to eql(true)
        end

        it "returns false if unsuccessful" do
          @conversation.stub(:update_attributes).and_return(false)
          @result = Conversation.remove_conv(@conversation, @recipient)
          expect(@result).to eql(false)
        end

        it "sets user's status to removed" do
          @result = Conversation.remove_conv(@conversation, @recipient)
          expect(@conversation.recipient_status).to eql('removed')
        end

        it "does not set recipient_status to be removed" do
          @result = Conversation.remove_conv(@conversation, @recipient)
          expect(@conversation.status).to eql("active")
        end

        it "sets user's posts to removed" do
          @result = Conversation.remove_conv(@conversation, @recipient)
          @conversation.posts.each do |post|
            if post.recipient_id == @recipient.id
              expect(post.status).to eql('active')
            end
          end
        end

        it "does not set other user's posts to removed" do
          @result = Conversation.remove_conv(@conversation, @recipient)
          @conversation.posts.each do |post|
            if post.recipient != @recipient.id
              expect(post.status).to eql('active')
            end
          end
        end
      end
    end

    describe "getting conversations" do
      before(:each) do
          @listing2 = FactoryGirl.create :listing, seller_id: @user.id, title: 'Small Guitar'
          @conversation2 = @listing2.conversations.create FactoryGirl.attributes_for :conversation, user_id: @recipient.id, recipient_id: @user.id
          @post2 = @conversation2.posts.create FactoryGirl.attributes_for :post, user_id: @recipient.id, recipient_id: @user.id, pixi_id: @listing2.pixi_id
      end

      context 'active' do
        it "returns active conversations" do
          Conversation.active.should include(@conversation)
          Conversation.active.should include(@conversation2)
        end

        it "doesn't return non-active conversations" do
          @conversation2.status = 'removed'
          @conversation2.recipient_status = 'removed'
          @conversation2.save
          expect(Conversation.active.count).to eql(1)
          Conversation.active.should include(@conversation)
          Conversation.active.should_not include(@conversation2)
        end

        it "correctly activates conversations" do
          @conversation2.status = ''
          @conversation2.save
          @conversation2.activate
          @conversation2.save
          expect(@conversation2.status).to eql('active')
        end
      end

      # test get_conversations, get_specific_conversations and inc_list
      it "gets correct number of conversations" do
        expect(Conversation.get_conversations(@user).count).to eql(2)
      end

      it "gets first conversation" do
        Conversation.get_conversations(@user).should include(@conversation)
      end

      it "gets second conversation" do
        Conversation.get_conversations(@user).should include(@conversation2)
      end

      it "only gets active conversations" do
        @conversation2.status = 'removed'
        @conversation2.recipient_status = 'removed'
        @conversation2.save
        expect(Conversation.get_conversations(@user).count).to eql(1)
        Conversation.get_conversations(@user).should_not include(@conversation2)
      end

      context 'getting specific conversations' do
        it "gets sent conversations" do
          Conversation.get_specific_conversations(@user, "sent").should include(@conversation)
          Conversation.usr_msg?(@conversation, @user).should be_true
          expect(Conversation.get_specific_conversations(@user, "sent").count).to eql(1)
        end

        it "only gets active sent conversations" do
          @conversation.status = 'removed'
          @conversation.save
          Conversation.usr_msg?(@conversation, @user).should_not be_true
          Conversation.get_specific_conversations(@user, "sent").should_not include(@conversation)
        end

        it "gets received conversations" do
          Conversation.get_specific_conversations(@user, "received").should include(@conversation2)
          Conversation.usr_msg?(@conversation2, @user).should be_true
          expect(Conversation.get_specific_conversations(@user, "received").count).to eql(1)
        end

        it "only gets active received conversations" do
          @conversation2.recipient_status = 'removed'
          @conversation2.save
          Conversation.usr_msg?(@conversation2, @user).should_not be_true
          Conversation.get_specific_conversations(@user, "received").should_not include(@conversation2)
        end
      end
    end

    describe 'replied_conv' do

      context 'with only one message' do
        it 'does not return true when user has not replied' do
          expect(@conversation.replied_conv?(@recipient)).to be false
        end

        it 'does not return true when user sent only message' do
          expect(@conversation.replied_conv?(@user)).to be false
        end
      end

      context 'with multiple messages' do
        before(:each) do
          @reply_post = @conversation.posts.create FactoryGirl.attributes_for :post, user_id: @recipient.id, recipient_id: @user.id, pixi_id: @listing.pixi_id, content: 'hello'
        end

        it 'does return true when user has replied' do
          expect(@conversation.replied_conv?(@recipient)).to be true
        end

        it 'does not return true when user has not replied' do
          expect(@conversation.replied_conv?(@user)).to be false
        end
      end
    end

  describe "content_msg" do 

    it "returns a long message" do 
      @post.content = "a" * 100 
      @post.save!
      @conversation.content_msg.length.should be > 35 
    end

    it "does not return a long message" do 
      @conversation.posts.first.content = "a" * 20 
      @conversation.save!
      @conversation.content_msg.length.should_not be > 35 
    end
  end

  describe "system_msg?" do 
    it { expect(@conversation.system_msg?).to be_nil } 

    it "returns true" do 
      @post.msg_type = 'approve' 
      @post.save!
      expect(@conversation.system_msg?).not_to be_nil
    end
  end

  describe "pixi_title" do 
    it { @conversation.pixi_title.should_not be_empty } 

    it "should not find correct pixi_title" do 
      @conversation.pixi_id = '100' 
      @conversation.pixi_title.should be_nil 
    end
  end

  describe "invoice_id" do 
    it 'returns invoice id' do
      @invoice = @user.invoices.build FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @recipient.id)
      sleep 2;
      @invoice.save
      @conversation.invoice_id.should_not be_nil  
    end

    it "should not find correct invoice_id" do 
      @conversation.pixi_id = '100' 
      @conversation.invoice_id.should be_nil 
    end
  end

  describe "due_invoice" do 
    
    it "should_not return true" do
      @conversation.due_invoice?(@user).should_not be_true
    end
    
    it "should return true" do
      @invoice = @buyer.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @recipient.id)
      @conversation.due_invoice?(@recipient).should be_true
    end
    
    it "should not return true when paid" do
      @new_user = FactoryGirl.create :pixi_user, first_name: 'Jack', last_name: 'Wilson', email: 'jack.wilson@pixitest.com'
      @account = @new_user.bank_accounts.create FactoryGirl.attributes_for :bank_account
      @invoice = @new_user.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @recipient.id)
      @invoice.status = 'paid'
      @invoice.save
      @conversation.due_invoice?(@recipient).should_not be_true
    end
    
    it "should not return true when removed" do
      @new_user = FactoryGirl.create :pixi_user, first_name: 'Jack', last_name: 'Wilson', email: 'jack.wilson@pixitest.com'
      @invoice = @new_user.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @recipient.id)
      @listing.status = 'removed'
      @listing.save; sleep 1
      @conversation.due_invoice?(@recipient).should_not be_true
    end
    
    it "should not return true when sold" do
      @new_user = FactoryGirl.create :pixi_user, first_name: 'Jack', last_name: 'Wilson', email: 'jack.wilson@pixitest.com'
      @invoice = @new_user.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @recipient.id)
      @listing.status = 'sold'
      @listing.save; sleep 1
      @conversation.due_invoice?(@recipient).should_not be_true
    end
  end

  describe 'can_bill?' do
    
    it "should_not return true" do
      @conversation.can_bill?(@recipient).should_not be_true
    end
    
    it "should return true" do
      @conversation.can_bill?(@user).should be_true
    end
    
    it "should not return true when paid" do
      @new_user = FactoryGirl.create :pixi_user, first_name: 'Jack', last_name: 'Wilson', email: 'jack.wilson@pixitest.com'
      @account = @new_user.bank_accounts.create FactoryGirl.attributes_for :bank_account
      @invoice = @new_user.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @recipient.id)
      @invoice.status = 'paid'
      @invoice.save
      @conversation.can_bill?(@recipient).should_not be_true
    end
    
    it "should not return true when removed" do
      @new_user = FactoryGirl.create :pixi_user, first_name: 'Jack', last_name: 'Wilson', email: 'jack.wilson@pixitest.com'
      @invoice = @new_user.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @recipient.id)
      @listing.status = 'removed'
      @listing.save; sleep 1
      @conversation.can_bill?(@recipient).should_not be_true
    end
    
    it "should not return true when sold" do
      @new_user = FactoryGirl.create :pixi_user, first_name: 'Jack', last_name: 'Wilson', email: 'jack.wilson@pixitest.com'
      @invoice = @new_user.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @recipient.id)
      @listing.status = 'sold'
      @listing.save; sleep 1
      @conversation.can_bill?(@recipient).should_not be_true
    end
  end

  describe 'create_dt' do
    it "does not show local updated date" do
      @conversation.created_at = nil
      expect(@conversation.create_dt.to_i).to be <= Time.now.to_i
    end

    it "show current created date" do
      expect(@conversation.create_dt).not_to eq @conversation.created_at
    end

    it "shows local created date" do
      @listing.lat, @listing.lng = 35.1498, -90.0492
      @listing.save
      # expect(@conversation.create_dt.to_i).to eq Time.now.to_i
      expect(@conversation.create_dt).not_to eq @conversation.created_at
    end
  end

  describe 'active_post_count' do
    it 'returns count > 0' do
      expect(@conversation.active_post_count(@user)).not_to eq 0
    end

    it 'returns count = 0 for user' do
      @post.status = 'removed'
      @post.save
      expect(@conversation.active_post_count(@user)).to eq 0
    end

    it 'returns count = 0 for recipient' do
      @post.recipient_status = 'removed'
      @post.save
      expect(@conversation.active_post_count(@recipient)).to eq 0
    end
  end

  describe 'mark_all_posts' do
    it 'marks posts' do
      expect(@conversation.mark_all_posts(@user)).not_to be_false
    end

    it 'marks no posts' do
      expect(@conversation.mark_all_posts(nil)).to be_false
    end
  end
end
