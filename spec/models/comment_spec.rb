require 'spec_helper'

describe Comment do
  let(:user) { FactoryGirl.create(:pixi_user) }
  let(:listing) { FactoryGirl.create(:listing, seller_id: user.id) }

  before do
    @category = FactoryGirl.create(:category, pixi_type: 'premium') 
    @comment = listing.comments.build(content: "Lorem ipsum", user_id: user.id)
  end

  subject { @comment }

  it { is_expected.to respond_to(:content) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:pixi_id) }
  its(:listing) { should == listing }

  it { is_expected.to be_valid }

  describe "when user_id is not present" do
    before { @comment.user_id = nil }
    it { is_expected.not_to be_valid }
  end

  describe "when pixi_id is not present" do
    before { @comment.pixi_id = nil }
    it { is_expected.not_to be_valid }
  end

  describe "large content" do 
    before { @comment.content = "a" * 500 }

    it "should return a summary of 40 chars" do 
      expect(@comment.summary.length).to eq(40) 
    end

    it "long content should return true" do 
      expect(@comment.long_content?).to be_truthy 
    end

    it "full content should be valid" do 
      expect(@comment.full_content).to be_truthy 
    end
  end

  describe "should not return a short content" do 
    before { @comment.content = "a" * 20 }

    it "should not return a summary of 40 chars" do 
      expect(@comment.summary.length).not_to eq(40) 
    end

    it "long content should not return true" do 
      expect(@comment.long_content?).not_to be_truthy 
    end

    it "full content should not be valid" do 
      @comment.content = nil
      expect(@comment.full_content).not_to be_truthy 
    end
  end


  describe "sender name" do 
    it { expect(@comment.sender_name).to eq("Joe Blow") } 

    it "does not return sender name" do 
      @comment.user_id = 100 
      expect(@comment.sender_name).to be_nil 
    end
  end

  describe "get_by_pixi" do 
    it { expect(Comment.get_by_pixi(0, 1)).not_to include @comment } 
    it 'has comments' do
      @comment.save
      expect(Comment.get_by_pixi(@comment.pixi_id, 1)).to include(@comment)
    end
  end
end
