require 'spec_helper'

describe Post do
  before(:each) do
    @user = FactoryGirl.create :pixi_user
    @recipient = FactoryGirl.create :pixi_user, first_name: 'Tom', last_name: 'Davis', email: 'tom.davis@pixitest.com'
    @buyer = FactoryGirl.create :pixi_user, first_name: 'Jack', last_name: 'Smith', email: 'jack.smith99@pixitest.com'
    @listing = FactoryGirl.create :listing, seller_id: @user.id, title: 'Big Guitar'
    @post = @listing.posts.build FactoryGirl.attributes_for :post, user_id: @user.id, recipient_id: @recipient.id
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
      Post.send_invoice(@invoice, @listing).should be_true
    end
    
    it "should not return true" do
      Post.send_invoice(@invoice, @listing).should_not be_true
    end
  end

  describe "add post" do 
    let(:msg) { "Test msg" }
    before do
      @person = FactoryGirl.create :pixi_user, first_name: 'Jim', last_name: 'Smith', email: 'jim.smith@pixitest.com'
      @invoice = @person.invoices.build FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @recipient.id)
    end
    
    it "should return true" do
      Post.add_post(@invoice, @listing, @person.id, @recipient.id, msg).should be_true
    end
    
    it "should not return true" do
      Post.add_post(@invoice, @listing, @person.id, nil, msg).should_not be_true
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
    it { @post.sender_name.should == "Joe Blow" } 

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

  describe "system_msg?" do 
    it { expect(@post.system_msg?).to be_nil } 

    it "returns true" do 
      @post.msg_type = 'approve' 
      expect(@post.system_msg?).not_to be_nil
    end
  end
end
