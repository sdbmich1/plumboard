require 'spec_helper'
include ProcessMethod

describe Post do
  before :all do
    @user = create :pixi_user
    @recipient = create :pixi_user, first_name: 'Tom', last_name: 'Davis', email: 'tom.davis@pixitest.com'
    @buyer = create :pixi_user, first_name: 'Jack', last_name: 'Smith', email: 'jack.smith99@pixitest.com'
    @listing = create :listing, seller_id: @user.id, title: 'Big Guitar', status: 'active'
    @conversation = @listing.conversations.create FactoryGirl.attributes_for :conversation, user_id: @user.id, recipient_id: @recipient.id
  end
  before(:each) do
    @post = @conversation.posts.build FactoryGirl.attributes_for :post, user_id: @user.id, recipient_id: @recipient.id, pixi_id: @listing.pixi_id
  end

  def add_invoice
    @new_user = FactoryGirl.create :pixi_user, first_name: 'Jack', last_name: 'Wilson', email: 'jack.wilson@pixitest.com'
    @invoice = @new_user.invoices.build FactoryGirl.attributes_for(:invoice, buyer_id: @recipient.id)
    @details = @invoice.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: @listing.pixi_id 
    @invoice.save!
  end
   
  subject { @post }

  describe 'attributes', base: true do
    let(:attr) { ProcessMethod::get_attr(@post, %w(id created_at updated_at)) }
    it_behaves_like "model attributes"
    it_behaves_like "model methods", %w(user listing recipient conversation)
    it { is_expected.to belong_to(:recipient).with_foreign_key('recipient_id').class_name('User') }
    it { is_expected.to belong_to(:conversation) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:listing).with_foreign_key('pixi_id') }
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:pixi_id) }
    it { is_expected.to validate_presence_of(:recipient_id) }
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_presence_of(:conversation) }
    it { is_expected.not_to allow_value('').for(:content) }
    it { is_expected.not_to allow_value(nil).for(:content) }
  end

  describe "load post", process: true do
    it "should load new post" do
      expect(Post.load_new(@listing)).not_to be_nil
    end

    it "should not load new post" do
      expect(Post.load_new(nil)).to be_nil
    end
  end
  
  describe "large content", process: true do 
    before { @post.content = "a" * 500 }

    it "should return a summary of 100 chars" do 
      expect(@post.summary.length).to eq(100) 
    end

    it "should return a summary of 50 chars" do 
      expect(@post.summary(50).length).to eq(50) 
    end

    it "should return a summary of 50 chars w/ ellipses" do 
      expect(@post.summary(50, true).length).to eq(53) 
    end

    it "long content should return true" do 
      expect(@post.long_content?).to be_truthy 
    end

    it "full content should be valid" do 
      expect(@post.full_content).to be_truthy 
    end
  end

  describe "should not return a short content", process: true do 
    before { @post.content = "a" * 50 }

    it "should not return a summary of 100 chars" do 
      expect(@post.summary.length).not_to eq(100) 
    end

    it "long content should not return true" do 
      expect(@post.long_content?).not_to be_truthy 
    end

    it "full content should not be valid" do 
      @post.content = nil
      expect(@post.full_content).not_to be_truthy 
    end
  end

  describe "read posts", process: true do 
    before { @post.save; sleep 2 }

    it "should return a post - get_posts" do 
      expect(Post.get_posts(@recipient)).not_to be_nil 
    end

    it "should not return an inactive post - get_posts" do
      @post.recipient_status = 'removed'
      @post.save
      expect(Post.get_posts(@recipient).count).to eq(0)
    end

    it "should not return a post - get_posts" do 
      expect(Post.get_posts(@user)).to be_empty 
    end

    it "returns sent posts" do 
      @listing.posts.create FactoryGirl.attributes_for :post, user_id: @user.id, recipient_id: @recipient.id
      expect(Post.get_sent_posts(@user)).not_to be_empty 
    end

    it "does not return sent posts" do 
      expect(Post.get_sent_posts(@buyer)).to be_empty 
    end
  end

  describe "unread count", process: true do 
    before { @post.save }

    it "should return a count > 0" do 
      expect(Post.unread_count(@post.recipient)).to eq(1) 
    end

    it "should not return a count > 0" do 
      expect(Post.unread_count(@user)).not_to eq(1) 
    end

    it "should return a post - get_unread" do 
      expect(Post.get_unread(@recipient)).not_to be_nil 
    end

    it "should not return a post - get_unread" do 
      expect(Post.get_unread(@user)).to be_empty 
    end
  end

  describe "sender", process: true do 
    
    it "should return true" do
      expect(@post.sender?(@user)).to be_truthy
    end
    
    it "should not return true" do
      expect(@post.sender?(@recipient)).not_to be_truthy
    end
  end

  describe "send_invoice", invoice: true do 
    before { @post.save }
    
    it "should return true" do
      @person = create :pixi_user, first_name: 'Jim', last_name: 'Smith', email: 'jim.smith@pixitest.com'
      @invoice = @person.invoices.build FactoryGirl.attributes_for(:invoice, buyer_id: @recipient.id)
      @details = @invoice.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: @listing.pixi_id 
      @invoice.save!
      @conversation2 = @listing.conversations.create FactoryGirl.attributes_for :conversation, user_id: @person.id, recipient_id: @recipient.id
      sleep 3
      expect(Post.send_invoice(@invoice, @listing)).to be_truthy
    end
    
    it "should not return true" do
      expect(Post.send_invoice(@invoice, @listing)).not_to be_truthy
    end
  end

  describe "add post", invoice: true do 
    let(:msg) { "Test msg" }
    before do
      @post.save; sleep 2
      @new_pixi = create :listing, seller_id: @user.id, title: 'Big Guitar'
      @person = create :pixi_user, first_name: 'Jim', last_name: 'Smith', email: 'jim.smith@pixitest.com'
      @conversation2 = @new_pixi.conversations.create FactoryGirl.attributes_for :conversation, user_id: @person.id, recipient_id: @user.id
      @post2 = @conversation2.posts.create FactoryGirl.attributes_for :post, user_id: @person.id, recipient_id: @user.id, pixi_id: @new_pixi.pixi_id,
        msg_type: 'want'
      @invoice = @user.invoices.build FactoryGirl.attributes_for(:invoice, buyer_id: @person.id)
      @details = @invoice.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: @listing.pixi_id 
      @invoice.save!
    end
    
    it "should return true" do
      sleep 2
      expect(Post.add_post(@invoice, @new_pixi, @user, @person, msg, 'invmsg')).to be_truthy
    end
    
    it "should not return true" do
      expect(Post.add_post(@invoice, @new_pixi, @person, nil, msg, 'invmsg')).not_to be_truthy
    end
  end

  describe "can_bill?", invoice: true do 
    before do
      @post.save 
    end

    it "seller returns true" do
      expect(@post.can_bill?(@user)).to be_truthy
    end

    it "buyer returns false" do
      expect(@post.can_bill?(@recipient)).not_to be_truthy
    end
    
    it "returns true" do
      add_invoice
      expect(@post.can_bill?(@new_user)).to be_truthy
    end
    
    it "does not return true when paid" do
      px_user = create :pixi_user
      @listing.update_attribute(:quantity, 3)
      @conversation2 = @listing.conversations.create attributes_for :conversation, user_id: px_user.id, recipient_id: @user.id
      @post2 = @conversation.posts.build attributes_for :post, user_id: px_user.id, recipient_id: @user.id, pixi_id: @listing.pixi_id
      @post2.save
      add_invoice
      @invoice.status = 'paid'
      @invoice.save!
      expect(@post.reload.can_bill?(@user)).not_to be_truthy
      expect(@post2.reload.can_bill?(@user)).to be_truthy
    end
    
    it "should not return true when removed" do
      @listing.status = 'removed'
      @listing.save; sleep 2
      expect(@post.reload.can_bill?(@user)).not_to be_truthy
    end
    
    it "should not return true when sold" do
      @listing.status = 'sold'
      @listing.save; sleep 1
      expect(@post.reload.can_bill?(@user)).not_to be_truthy
    end
  end

  describe "due_invoice", invoice: true do 
    before { @post.save }
    it "should_not return true" do
      expect(@post.due_invoice?(@user)).not_to be_truthy
    end
    
    context 'with invoice' do
      before :each do
        add_invoice
      end

      it { expect(@post.due_invoice?(@recipient)).to be_truthy }
    
      it "should not return true when paid" do
        @invoice.update_attribute(:status, 'paid')
        expect(@post.reload.due_invoice?(@recipient)).not_to be_truthy
      end
    
      it "should not return true when removed" do
        @listing.status = 'removed'
        @listing.save; sleep 3
        expect(@post.reload.due_invoice?(@recipient)).not_to be_truthy
      end
    end
  end

  describe "pay_invoice", invoice: true do 
    before do
      @new_user = create :pixi_user, first_name: 'Jack', last_name: 'Wilson', email: 'jack.wilson@pixitest.com'
      @txn = @buyer.transactions.build FactoryGirl.attributes_for :transaction, transaction_type: 'invoice' 
    end
    
    it "should not return true" do
      expect(Post.pay_invoice(@txn)).not_to be_truthy
    end
    
    it "should return true" do
      @txn.save!
      @invoice = @txn.invoices.build FactoryGirl.attributes_for(:invoice, buyer_id: @buyer.id, seller_id: @new_user.id)
      @details = @invoice.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: @listing.pixi_id 
      @invoice.save!; sleep 2
      expect(@txn.invoices.size).to eq 1
      expect(Post.pay_invoice(@txn)).to be_truthy
    end
  end

  describe "sender name", process: true do 
    it { expect(@post.sender_name).to eq(@user.first_name + " " + @user.last_name) }

    it "does not return sender name" do 
      @post.user_id = 100 
      expect(@post.sender_name).to be_nil 
    end
  end

  describe "recipient name", process: true do 
    it { expect(@post.recipient_name).to eq("Tom Davis") } 

    it "does not return recipient name" do 
      @post.recipient_id = 100 
      expect(@post.recipient_name).to be_nil 
    end
  end

  describe "sender email", process: true do 
    it { expect(@post.sender_email).to eq(@user.email) } 

    it "does not return sender email" do 
      @post.user_id = 100 
      expect(@post.sender_email).to be_nil 
    end
  end

  describe "recipient email", process: true do 
    it { expect(@post.recipient_email).to eq(@recipient.email) } 

    it "does not return recipient email" do 
      @post.recipient_id = 100 
      expect(@post.recipient_email).to be_nil 
    end
  end

  describe "pixi title", process: true do 
    it { expect(@post.pixi_title).to eq("Big Guitar") } 

    it "does not return pixi title" do 
      @post.pixi_id = 100 
      expect(@post.pixi_title).to be_nil 
    end
  end

  describe "msg?", process: true do 
    %w(ask want inv).each do |val|
      it { expect(@post.send("#{val}_msg?")).to eq(false) } 
      it "returns true" do 
        @post.msg_type = val
        expect(@post.send("#{val}_msg?")).to eq(true) 
      end
    end
  end

  def sys_msg model, val
    model.msg_type = val
    expect(model.system_msg?).not_to be_nil
  end

  describe "system_msg?", process: true do 
    it { expect(@post.system_msg?).to be_nil } 

    it "returns true" do 
      %w(approve repost deny system).each do |msg|
        sys_msg @post, msg
      end
    end
  end

  describe "checking existence of conversation", process: true do
    it "has a conversation" do
      expect(@post.conversation).not_to be_nil
    end

    it "is invalid without a conversation" do
      @post.conversation_id = ""
      expect(@post).not_to be_valid
    end

    it "is valid with a conversation" do
      expect(@post).to be_valid
    end
  end

  describe "mapping posts to conversations", process: true do
    before { @post.save; sleep 2 }
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
        Post.map_posts_to_conversations
        @conversation2 = Conversation.find(:first, :conditions => ["pixi_id = ? AND recipient_id = ?", @post.pixi_id, @post.recipient_id])
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
        Post.map_posts_to_conversations
        @post = Post.find(:first, :conditions => ["pixi_id = ? AND user_id = ?", @post.pixi_id, @user.id])
        @post2 = Post.find(:first, :conditions => ["pixi_id = ? AND user_id = ?", @post2.pixi_id, @recipient.id])
        @conversation2 = Conversation.find(:first, :conditions => ["pixi_id = ? AND recipient_id = ?", @post.pixi_id, 
                                                                   @post.recipient_id])
        @user_id = @conversation2.user_id
        @recipient_id = @conversation2.recipient_id
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

  describe 'active_status', process: true do
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
      @post.save
      expect(Post.active_status(@user)).not_to be_empty
      expect(Post.active_status(@recipient)).not_to be_empty
    end
  end

  describe "removing posts", process: true do

    context "removing user's post" do

      it "returns true if successful" do
        @result = @post.remove_post(@user)
        expect(@result).to eql(true)
      end

      it "returns false if unsuccessful" do
        allow(@post).to receive(:update_attributes).and_return(false)
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
        allow(@post).to receive(:update_attributes).and_return(false)
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

  describe 'create_dt', process: true do
    it "does not show local updated date" do
      @post.created_at = nil
      expect(@post.create_dt.to_i).to eq Time.now.to_i
    end

    it "shows local created date" do
      @post.save
      @listing.lat, @listing.lng = 35.1498, -90.0492
      @listing.save
      expect(@post.create_dt.to_i).to eq @post.created_at.to_i
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

    it 'processes ask request' do
      new_conv 'ask'
      expect(PixiAsk.count).to eq 1
    end

    it 'does not process ask request' do
      new_conv 'inv'
      expect(PixiAsk.count).not_to eq 1
    end
  end

  describe 'update_counter_cache', process: true do
    it "updates cache on create" do
      @post.save!
      expect(@conversation.reload.active_posts_count).to eq 1
    end
    it "updates cache on update" do
      @post.save!
      @post.update_attributes(status: 'removed', recipient_status: 'removed')
      expect(Post.active.size).to eq 0
      expect(@conversation.reload.active_posts_count).to eq 0
    end
  end
end
