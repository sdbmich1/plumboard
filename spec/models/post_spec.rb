require 'spec_helper'

describe Post do
  before(:each) do
    @user = FactoryGirl.create :pixi_user
    @recipient = FactoryGirl.create :pixi_user, first_name: 'Tom', last_name: 'Davis'
    @listing = FactoryGirl.create :listing, seller_id: @user.id
    @post = FactoryGirl.build :post, user: @user, recipient: @recipient, listing: @listing, pixi_id: @listing.pixi_id
  end
   
  subject { @post }

  it { should respond_to(:content) }
  it { should respond_to(:listing_id) }
  it { should respond_to(:user_id) }
  it { should respond_to(:pixi_id) }
  it { should respond_to(:recipient_id) }

  it { should respond_to(:user) }
  it { should respond_to(:listing) }
  it { should respond_to(:recipient) }

  describe "when content is empty" do
    before { @post.content = "" }
    it { should_not be_valid }
  end

  describe "when content is not empty" do
    it { should be_valid }
  end

  describe "when listing_id is empty" do
    before { @post.listing_id = "" }
    it { should_not be_valid }
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

  describe "unread count" do 
    before { @post.save }

    it "should return a count > 0" do 
      Post.unread_count(@post.recipient).should == 1 
    end

    it "should not return a count > 0" do 
      Post.unread_count(@user).should_not == 1 
    end

    it "should return a post" do 
      Post.get_unread(@recipient).should_not be_nil 
    end

    it "should not return a post" do 
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
end
