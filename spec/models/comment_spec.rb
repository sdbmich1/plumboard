require 'spec_helper'

describe Comment do
  let(:user) { FactoryGirl.create(:pixi_user) }
  let(:listing) { FactoryGirl.create(:listing, seller_id: user.id) }

  before do
    @category = FactoryGirl.create(:category, pixi_type: 'premium') 
    @comment = listing.comments.build(content: "Lorem ipsum", user_id: user.id)
  end

  subject { @comment }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:pixi_id) }
  its(:listing) { should == listing }

  it { should be_valid }

  describe "when user_id is not present" do
    before { @comment.user_id = nil }
    it { should_not be_valid }
  end

  describe "when pixi_id is not present" do
    before { @comment.pixi_id = nil }
    it { should_not be_valid }
  end

  describe "large content" do 
    before { @comment.content = "a" * 500 }

    it "should return a summary of 30 chars" do 
      @comment.summary.length.should == 30 
    end

    it "long content should return true" do 
      @comment.long_content?.should be_true 
    end

    it "full content should be valid" do 
      @comment.full_content.should be_true 
    end
  end

  describe "should not return a short content" do 
    before { @comment.content = "a" * 20 }

    it "should not return a summary of 30 chars" do 
      @comment.summary.length.should_not == 30 
    end

    it "long content should not return true" do 
      @comment.long_content?.should_not be_true 
    end

    it "full content should not be valid" do 
      @comment.content = nil
      @comment.full_content.should_not be_true 
    end
  end


  describe "sender name" do 
    it { @comment.sender_name.should == "Joe Blow" } 

    it "does not return sender name" do 
      @comment.user_id = 100 
      @comment.sender_name.should be_nil 
    end
  end
end
