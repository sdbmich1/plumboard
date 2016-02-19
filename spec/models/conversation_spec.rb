require 'spec_helper'

describe Conversation do
    before :all do
      @user = create :pixi_user
      @recipient = create :pixi_user, first_name: 'Tom', last_name: 'Davis', email: 'tom.davis@pixitest.com'
      @buyer = create :pixi_user, first_name: 'Jack', last_name: 'Smith', email: 'jack.smith99@pixitest.com'
      @listing = create :listing, seller_id: @user.id, title: 'Big Guitar'
    end
    before :each do
      @conversation = @listing.conversations.create attributes_for :conversation, user_id: @user.id, recipient_id: @recipient.id
      @post = @conversation.posts.create attributes_for :post, user_id: @user.id, recipient_id: @recipient.id, pixi_id: @listing.pixi_id
    end

    subject { @conversation }

    it { should respond_to(:user_id) }
    it { should respond_to(:pixi_id) }
    it { should respond_to(:recipient_id) }
    it { should respond_to(:user) }
    it { should respond_to(:listing) }
    it { should respond_to(:recipient) }
    it { should respond_to(:posts) }
    it { should respond_to(:fulfillment_type_code) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:pixi_id) }
    it { should validate_presence_of(:recipient_id) }
    it { should have_many(:active_posts).class_name('Post').conditions(:status=>"active") }

    describe "when accessing posts" do
      it "has first post" do
        expect(@conversation.posts.first).not_to be_nil
      end
    end

    describe "removing posts" do
      before(:each) do
        @post = @conversation.posts.create attributes_for :post, user_id: @recipient.id, recipient_id: @user.id, pixi_id: @listing.pixi_id
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
          expect(Conversation.remove_conv(@conversation, @user)).to eql(true)
        end

        it "returns false if unsuccessful" do
	  new_user = create :pixi_user
          expect(Conversation.remove_conv(@conversation, new_user)).to eql(false)
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
          expect(Conversation.remove_conv(@conversation, @recipient)).to eql(true)
        end

        it "returns false if unsuccessful" do
	  new_user = create :pixi_user
          expect(Conversation.remove_conv(@conversation, new_user)).to eql(false)
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
          @listing2 = create :listing, seller_id: @user.id, title: 'Small Guitar'
          @conversation2 = @listing2.conversations.create attributes_for :conversation, user_id: @recipient.id, recipient_id: @user.id
          @post2 = @conversation2.posts.create attributes_for :post, user_id: @recipient.id, recipient_id: @user.id, pixi_id: @listing2.pixi_id
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
          expect(Conversation.get_specific_conversations(@user, "sent").count).to eql(1)
        end

        it "only gets active sent conversations" do
          @conversation.status = 'removed'
          @conversation.save
          Conversation.get_specific_conversations(@user, "sent").should_not include(@conversation)
        end

        it "gets received conversations" do
          Conversation.get_specific_conversations(@user, "received").should include(@conversation2)
          expect(Conversation.get_specific_conversations(@user, "received").count).to eql(1)
        end

        it "only gets active received conversations" do
          @conversation2.recipient_status = 'removed'
          @conversation2.save
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
          @reply_post = @conversation.posts.create attributes_for :post, user_id: @recipient.id, recipient_id: @user.id, pixi_id: @listing.pixi_id, content: 'hello'
        end

        it 'does return true when user has replied' do
          expect(@conversation.replied_conv?(@user)).to be_true
        end

        it 'does not return true when user has not replied' do
	  new_user = create :pixi_user
          expect(@conversation.replied_conv?(new_user)).to be false
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

  describe "due_invoice", invoice: true do 
    before :each, run: true do
      @new_user = create :pixi_user, first_name: 'Jack', last_name: 'Wilson', email: 'jack.wilson@pixitest.com'
      @account = @new_user.bank_accounts.create attributes_for :bank_account
      @invoice = @new_user.invoices.create attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @recipient.id)
      @details = @invoice.invoice_details.build attributes_for :invoice_detail, pixi_id: @listing.pixi_id 
      @invoice.save!
    end
    
    it "should_not return true" do
      @conversation.due_invoice?(@user).should_not be_true
      @conversation.sender_due_invoice?.should_not be_true
    end
    
    it "should return true" do
      @invoice = @buyer.invoices.build attributes_for(:invoice, buyer_id: @recipient.id)
      @details = @invoice.invoice_details.build attributes_for :invoice_detail, pixi_id: @listing.pixi_id 
      @invoice.save!
      @conversation.due_invoice?(@recipient).should be_true
      @conversation.recipient_due_invoice?.should be_true
    end
    
    it "should not return true when paid", run: true do
      @invoice.status = 'paid'
      @invoice.save
      @conversation.due_invoice?(@recipient).should_not be_true
      @conversation.recipient_due_invoice?.should_not be_true
    end
    
    it "should not return true when removed", run: true do
      @listing.status = 'removed'
      @listing.save; sleep 1
      @conversation.due_invoice?(@recipient).should_not be_true
      @conversation.recipient_due_invoice?.should_not be_true
    end
  end

  describe 'can_bill?', invoice: true do
    before :each do
      @new_user = create :pixi_user, first_name: 'Jack', last_name: 'Wilson', email: 'jack.wilson@pixitest.com'
      @account = @new_user.bank_accounts.create attributes_for :bank_account
      @invoice = @new_user.invoices.build attributes_for(:invoice, buyer_id: @recipient.id)
      @details = @invoice.invoice_details.build attributes_for :invoice_detail, pixi_id: @listing.pixi_id 
      @invoice.save!
    end
    
    it "should_not return true" do
      @conversation.can_bill?(@recipient).should_not be_true
      @conversation.recipient_can_bill?.should_not be_true
    end
    
    it "returns true" do
      @conversation.can_bill?(@new_user).should be_true
    end

    it "sender_can_bill? returns true" do
      @conversation.update_attribute(:user_id, @new_user.id)
      @conversation.sender_can_bill?.should be_true
    end
    
    it "should not return true when paid" do
      @invoice.status = 'paid'
      @invoice.save!
      @conversation.can_bill?(@recipient).should_not be_true
      @conversation.recipient_can_bill?.should_not be_true
    end
    
    it "should not return true when removed" do
      @listing.status = 'removed'
      @listing.save; sleep 1
      @conversation.can_bill?(@recipient).should_not be_true
      @conversation.recipient_can_bill?.should_not be_true
    end
    
    it "should not return true when sold" do
      @listing.status = 'sold'
      @listing.save; sleep 1
      @conversation.can_bill?(@recipient).should_not be_true
      @conversation.recipient_can_bill?.should_not be_true
    end
  end

  describe 'create_dt' do
    it "does not show local updated date" do
      @conversation.created_at = nil
      expect(@conversation.create_dt.to_i).to be <= Time.now.to_i
    end

    it "show current created date" do
      expect(@conversation.create_dt.to_s).to eq @conversation.created_at.localtime.to_s
    end

    it "shows local created date" do
      @listing.lat, @listing.lng = 35.1498, -90.0492
      @listing.save
      # expect(@conversation.create_dt.to_i).to eq Time.now.to_i
      expect(@conversation.create_dt.to_s).to eq @conversation.created_at.localtime.to_s
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

  describe "get_conv" do 
    let(:msg) { "Test msg" }
    
    it "finds recipient as recipient" do
      expect(Conversation.first.posts.count).to eq 1
      expect(Conversation.get_conv @listing.pixi_id, @recipient.id, @user.id).not_to be_nil
    end
    
    it "finds user as recipient" do
      @post2 = @conversation.posts.create attributes_for :post, user_id: @recipient.id, recipient_id: @user.id, pixi_id: @listing.pixi_id
      expect(Conversation.first.posts.where(pixi_id: @listing.pixi_id).count).to eq 2
      expect(Conversation.first.posts.where('pixi_id = ? AND user_id = ?', @listing.pixi_id, @recipient.id).count).to eq 1
      expect(Conversation.first.posts.where('pixi_id = ? AND recipient_id = ?', @listing.pixi_id, @user.id).count).to eq 1
      expect(Conversation.get_conv(@listing.pixi_id, @user.id, @recipient.id)).not_to eq @post
    end
    
    it "should not return true" do
      expect(Conversation.get_conv nil, nil, nil).to be_nil
    end
  end

  describe 'process_pixi_requests' do
    it 'processes want request' do
      new_conv 'want'
      expect(PixiWant.first.quantity).to eq 2
    end
    
    it 'does not process want request' do
      new_conv 'inv'
      expect(PixiWant.count).not_to eq 1
    end

    it 'processes want request' do
      new_conv 'want'
      @conv.update_attribute(:status, 'removed')
      expect(PixiWant.count).to eq 1
    end
  end

  describe "sender name", process: true do 
    it { @conversation.sender_name.should == (@user.first_name + " " + @user.last_name) }

    it "does not return sender name" do 
      @conversation.user_id = 100 
      @conversation.sender_name.should be_nil 
    end
  end

  describe "recipient name", process: true do 
    it { @conversation.recipient_name.should == "Tom Davis" } 

    it "does not return recipient name" do 
      @conversation.recipient_id = 100 
      @conversation.recipient_name.should be_nil 
    end
  end

  describe "as_json" do
    it "contains mobile conversation fields" do
      json = @conversation.as_json(user: @user)
      %w(invoice_id sender_can_bill? recipient_can_bill? sender_due_invoice? recipient_due_invoice? get_posts).each do |fld|
        expect(json.keys).to include fld.to_sym
      end
      expect(json[:listing].keys).to include :photo_url
    end
  end

end
