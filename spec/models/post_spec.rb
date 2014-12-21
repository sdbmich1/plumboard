require 'spec_helper'

describe Post do
  before(:each) do
    @user = FactoryGirl.create :pixi_user
    @recipient = FactoryGirl.create :pixi_user, first_name: 'Tom', last_name: 'Davis', email: 'tom.davis@pixitest.com'
    @buyer = FactoryGirl.create :pixi_user, first_name: 'Jack', last_name: 'Smith', email: 'jack.smith99@pixitest.com'
    @listing = FactoryGirl.create :listing, seller_id: @user.id, title: 'Big Guitar'
    @conversation = @listing.conversations.create FactoryGirl.attributes_for :conversation, user_id: @user.id, recipient_id: @recipient.id
    @post = @conversation.posts.create FactoryGirl.attributes_for :post, user_id: @user.id, recipient_id: @recipient.id, pixi_id: @listing.pixi_id
  end
   
  subject { @post }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:pixi_id) }
  it { should respond_to(:recipient_id) }
  it { should respond_to(:msg_type) }
  it { should respond_to(:user) }
  it { should respond_to(:listing) }
  it { should respond_to(:recipient) }
  it { should respond_to(:invoice) }
  it { should respond_to(:conversation) }
  it { should respond_to(:conversation_id) }

  describe "when content is empty" do
    before { @post.content = "" }
    it { should_not be_valid }
  end

  describe "when content is not empty" do
    it { should be_valid }
  end

  describe "when user_id is empty" do
    before { @post.user_id = "" }
    it { should_not be_valid }
  end

  describe "when pixi_id is empty" do
    before { @post.pixi_id = "" }
    it { should_not be_valid }
  end

  describe "when recipient_id is empty" do
    before { @post.recipient_id = "" }
    it { should_not be_valid }
  end

  describe "load post" do
    it "should load new post" do
      Post.load_new(@listing).should_not be_nil
    end

    it "should not load new post" do
      Post.load_new(nil).should be_nil
    end
  end
  
  describe "large content" do 
    before { @post.content = "a" * 500 }

    it "should return a summary of 100 chars" do 
      @post.summary.length.should == 100 
    end

    it "should return a summary of 50 chars" do 
      @post.summary(50).length.should == 50 
    end

    it "should return a summary of 50 chars w/ ellipses" do 
      @post.summary(50, true).length.should == 53 
    end

    it "long content should return true" do 
      @post.long_content?.should be_true 
    end

    it "full content should be valid" do 
      @post.full_content.should be_true 
    end
  end

  describe "should not return a short content" do 
    before { @post.content = "a" * 50 }

    it "should not return a summary of 100 chars" do 
      @post.summary.length.should_not == 100 
    end

    it "long content should not return true" do 
      @post.long_content?.should_not be_true 
    end

    it "full content should not be valid" do 
      @post.content = nil
      @post.full_content.should_not be_true 
    end
  end

  describe "read posts" do 
    before { @post.save }

    it "should return a post - get_posts" do 
      Post.get_posts(@recipient).should_not be_nil 
    end

    it "should not return an inactive post - get_posts" do
      @post.recipient_status = 'removed'
      @post.save
      Post.get_posts(@recipient).count.should == 0
    end

    it "should not return a post - get_posts" do 
      Post.get_posts(@user).should be_empty 
    end

    it "returns sent posts" do 
      @listing.posts.create FactoryGirl.attributes_for :post, user_id: @user.id, recipient_id: @recipient.id
      Post.get_sent_posts(@user).should_not be_empty 
    end

    it "does not return sent posts" do 
      Post.get_sent_posts(@buyer).should be_empty 
    end
  end

  describe "unread count" do 
    before { @post.save }

    it "should return a count > 0" do 
      Post.unread_count(@post.recipient).should == 1 
    end

    it "should not return a count > 0" do 
      Post.unread_count(@user).should_not == 1 
    end

    it "should return a post - get_unread" do 
      Post.get_unread(@recipient).should_not be_nil 
    end

    it "should not return a post - get_unread" do 
      Post.get_unread(@user).should be_empty 
    end
  end

  describe "sender" do 
    
    it "should return true" do
      @post.sender?(@user).should be_true
    end
    
    it "should not return true" do
      @post.sender?(@recipient).should_not be_true
    end
  end

  describe "send_invoice" do 
    
    it "should return true" do
      @person = FactoryGirl.create :pixi_user, first_name: 'Jim', last_name: 'Smith', email: 'jim.smith@pixitest.com'
      @invoice = @person.invoices.build FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @recipient.id)
      @conversation2 = @listing.conversations.create FactoryGirl.attributes_for :conversation, user_id: @person.id, recipient_id: @recipient.id
      Post.send_invoice(@invoice, @listing).should be_true
    end
    
    it "should not return true" do
      Post.send_invoice(@invoice, @listing).should_not be_true
    end
  end

  describe "add post" do 
    let(:msg) { "Test msg" }
    before do
      @new_pixi = FactoryGirl.create :listing, seller_id: @user.id, title: 'Big Guitar'
      @person = FactoryGirl.create :pixi_user, first_name: 'Jim', last_name: 'Smith', email: 'jim.smith@pixitest.com'
      @conversation2 = @new_pixi.conversations.create FactoryGirl.attributes_for :conversation, user_id: @person.id, recipient_id: @user.id
      @post2 = @conversation2.posts.create FactoryGirl.attributes_for :post, user_id: @person.id, recipient_id: @user.id, pixi_id: @new_pixi.pixi_id,
        msg_type: 'want'
      @invoice = @user.invoices.build FactoryGirl.attributes_for(:invoice, pixi_id: @new_pixi.pixi_id, buyer_id: @person.id)
    end
    
    it "should return true" do
      Post.add_post(@invoice, @new_pixi, @user, @person, msg, 'invmsg').should be_true
      expect(Conversation.where(pixi_id: @new_pixi.pixi_id).size).to eq 1 
      expect(@conversation2.posts.size).to eq 2
    end
    
    it "should not return true" do
      Post.add_post(@invoice, @new_pixi, @person, nil, msg, 'invmsg').should_not be_true
    end
  end

  describe "due_invoice" do 
    
    it "should_not return true" do
      @post.due_invoice?(@user).should_not be_true
    end
    
    it "should return true" do
      @invoice = @buyer.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @recipient.id)
      @post.due_invoice?(@recipient).should be_true
    end
    
    it "should not return true when paid" do
      @new_user = FactoryGirl.create :pixi_user, first_name: 'Jack', last_name: 'Wilson', email: 'jack.wilson@pixitest.com'
      @account = @new_user.bank_accounts.create FactoryGirl.attributes_for :bank_account
      @invoice = @new_user.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @recipient.id)
      @invoice.status = 'paid'
      @invoice.save
      @post.due_invoice?(@recipient).should_not be_true
    end
    
    it "should not return true when removed" do
      @new_user = FactoryGirl.create :pixi_user, first_name: 'Jack', last_name: 'Wilson', email: 'jack.wilson@pixitest.com'
      @invoice = @new_user.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @recipient.id)
      @listing.status = 'removed'
      @listing.save; sleep 1
      @post.due_invoice?(@recipient).should_not be_true
    end
  end

  describe "pay_invoice" do 
    before do
      @new_user = FactoryGirl.create :pixi_user, first_name: 'Jack', last_name: 'Wilson', email: 'jack.wilson@pixitest.com'
      @txn = @buyer.transactions.create FactoryGirl.attributes_for :transaction, transaction_type: 'invoice' 
      @invoice = @listing.invoices.create FactoryGirl.attributes_for(:invoice, seller_id: @new_user.id, buyer_id: @buyer.id,
        transaction_id: @txn.id)
    end
    
    it "should not return true" do
      Post.pay_invoice(@txn).should_not be_true
    end

    it "should have an invoice" do
      @invoice.transaction.should_not be_nil
    end
    
    it "should return true" do
      Post.pay_invoice(@invoice.transaction).should be_true
    end
  end

  describe "sender name" do 
    it { @post.sender_name.should == (@user.first_name + " " + @user.last_name) }

    it "does not return sender name" do 
      @post.user_id = 100 
      @post.sender_name.should be_nil 
    end
  end

  describe "recipient name" do 
    it { @post.recipient_name.should == "Tom Davis" } 

    it "does not return recipient name" do 
      @post.recipient_id = 100 
      @post.recipient_name.should be_nil 
    end
  end

  describe "sender email" do 
    it { @post.sender_email.should == @user.email } 

    it "does not return sender email" do 
      @post.user_id = 100 
      @post.sender_email.should be_nil 
    end
  end

  describe "recipient email" do 
    it { @post.recipient_email.should == @recipient.email } 

    it "does not return recipient email" do 
      @post.recipient_id = 100 
      @post.recipient_email.should be_nil 
    end
  end

  describe "pixi title" do 
    it { @post.pixi_title.should == "Big Guitar" } 

    it "does not return pixi title" do 
      @post.pixi_id = 100 
      @post.pixi_title.should be_nil 
    end
  end

  describe "inv_msg?" do 
    it { expect(@post.inv_msg?).to eq(false) } 

    it "returns true" do 
      @post.msg_type = 'inv' 
      expect(@post.inv_msg?).to eq(true) 
    end
  end

  describe "want_msg?" do 
    it { expect(@post.want_msg?).to eq(false) } 

    it "returns true" do 
      @post.msg_type = 'want' 
      expect(@post.want_msg?).to eq(true) 
    end
  end

  def sys_msg model, val
    model.msg_type = val
    expect(model.system_msg?).not_to be_nil
  end

  describe "system_msg?" do 
    it { expect(@post.system_msg?).to be_nil } 

    it "returns true" do 
      sys_msg @post, 'approve'
      sys_msg @post, 'repost'
      sys_msg @post, 'deny'
      sys_msg @post, 'system'
    end
  end

  describe "checking existence of conversation" do
    it "has a conversation" do
      expect(@post.conversation).not_to be_nil
    end

    it "is invalid without a conversation" do
      @post.conversation_id = ""
      @post.should_not be_valid
    end

    it "is valid with a conversation" do
      @post.should be_valid
    end
  end

  describe "mapping posts to conversations" do
    it "doesn't create new conversation when posts have conversation already" do
      Post.map_posts_to_conversations
      expect(Conversation.all.count).to eq(1)
    end

    it "doesn't create new conversation when one already exists" do
      @post.conversation_id = nil
      @post.save(:validate => false)
      Post.map_posts_to_conversations
      expect(Conversation.all.count).to eql(1)
    end

    it "finds conversation that post is a part of" do
      Post.first.conversation_id = nil
      Post.first.save(:validate => false)
      Post.map_posts_to_conversations
      expect(Post.first.conversation_id).to eql(@conversation.id)
    end

    it "adds active status to posts" do
      Post.map_posts_to_conversations
      Post.all.each do |post|
          expect(post.status).to eq('active')
          expect(post.recipient_status).to eq('active')
      end
    end

    it "has active status for conversations" do
      Post.map_posts_to_conversations
      Conversation.all.each do |conv|
          expect(conv.status).to eq('active')
          expect(conv.recipient_status).to eq('active')
      end
    end

    context "creating new conversations with different listing posts" do
      before(:each) do
        @listing2 = FactoryGirl.create :listing, seller_id: @recipient.id, title: 'Small Guitar'
        @post2 = FactoryGirl.build :post, user_id: @user.id, recipient_id: @recipient.id, pixi_id: @listing2.pixi_id
        @post2.save(:validate => false)
        @post.conversation_id = nil
        @post.save(:validate => false)
        @conversation.recipient_id = nil
        @conversation.save(:validate => false)
        Post.map_posts_to_conversations
        @conversation2 = Conversation.find(:first, :conditions => ["pixi_id = ? AND recipient_id = ?", @post.pixi_id, 
                                                                   @post.recipient_id])
        @post = Post.find(:first, :conditions => ["pixi_id = ?", @post.pixi_id])
        @post2 = Post.find(:first, :conditions => ["pixi_id = ?", @post2.pixi_id])
      end

      it "only assigns conversation id to corresponding post" do
        expect(@post2.conversation_id).to_not eql(@conversation2.id)
        expect(@post.conversation_id).to eql(@conversation2.id)
      end
    end

    context "creating new conversations" do
      before(:each) do
        @post2 = FactoryGirl.build :post, user_id: @recipient.id, recipient_id: @user.id, pixi_id: @listing.pixi_id
        @post2.save(:validate => false)
        @post.conversation_id = nil
        @post.save(:validate => false)
        @conversation.recipient_id = nil
        @conversation.save(:validate => false)
        Post.map_posts_to_conversations
        @post = Post.find(:first, :conditions => ["pixi_id = ? AND user_id = ?", @post.pixi_id, @user.id])
        @post2 = Post.find(:first, :conditions => ["pixi_id = ? AND user_id = ?", @post2.pixi_id, @recipient.id])
        @conversation2 = Conversation.find(:first, :conditions => ["pixi_id = ? AND recipient_id = ?", @post.pixi_id, 
                                                                   @post.recipient_id])
        @user_id = @conversation2.user_id
        @recipient_id = @conversation2.recipient_id
      end

      it "creates new conversation when one doesn't already exist" do
        expect(Conversation.all.count).to eql(2)
      end

      it "assigns right conversation ids" do
        expect(@post.conversation_id).to eql(@post2.conversation_id)
        expect(@post.conversation_id).to eql(@conversation2.id)
      end

      it "assigns right user id" do
        expect(@user_id).to eql(@post.user_id)
      end

      it "assigns right recipient id" do
        expect(@recipient_id).to eql(@post.recipient_id)
      end
      
      it "assigns right pixi id" do
        expect(@conversation2.pixi_id).to eql(@listing.pixi_id)
      end
    end
  end

  describe 'active_status' do
    it 'returns nothing when user status is removed' do
      @post.status = 'removed'
      @post.save
      expect(Post.active_status(@user)).to be_empty
    end

    it 'returns nothing when recipient status is removed' do
      @post.recipient_status = 'removed'
      @post.save
      expect(Post.active_status(@recipient)).to be_empty
    end

    it 'returns active posts' do
      expect(Post.active_status(@user)).not_to be_empty
      expect(Post.active_status(@recipient)).not_to be_empty
    end
  end

  describe "removing posts" do

    context "removing user's post" do

      it "returns true if successful" do
        @result = @post.remove_post(@user)
        expect(@result).to eql(true)
      end

      it "returns false if unsuccessful" do
        @post.stub(:update_attributes).and_return(false)
        @result = @post.remove_post(@user)
        expect(@result).to eql(false)
      end

      it "sets user's status to removed" do
        @result = @post.remove_post(@user)
        expect(@post.status).to eql('removed')
      end

      it "does not set recipient_status to be removed" do
        @result = @post.remove_post(@user)
        expect(@post.recipient_status).to eql("active")
      end
    end

    context "removing recipient's post" do

      it "returns true if successful" do
        @result = @post.remove_post(@recipient)
        expect(@result).to eql(true)
      end

      it "returns false if unsuccessful" do
        @post.stub(:update_attributes).and_return(false)
        @result = @post.remove_post(@recipient)
        expect(@result).to eql(false)
      end

      it "sets user's status to removed" do
        @result = @post.remove_post(@recipient)
        expect(@post.recipient_status).to eql('removed')
      end

      it "does not set recipient_status to be removed" do
        @result = @post.remove_post(@recipient)
        expect(@post.status).to eql("active")
      end
    end
  end

  describe 'create_dt' do
    it "does not show local updated date" do
      @post.created_at = nil
      expect(@post.create_dt.to_i).to eq Time.now.to_i
    end

    it "shows local created date" do
      @listing.lat, @listing.lng = 35.1498, -90.0492
      @listing.save
      expect(@post.create_dt.to_i).to eq @post.created_at.to_i
    end
  end
end
