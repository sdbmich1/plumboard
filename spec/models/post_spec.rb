require 'spec_helper'

describe Post do
  before(:each) do
    @listing = FactoryGirl.create :listing
    @post = FactoryGirl.build :post, listing_id: @listing.id, pixi_id: @listing.pixi_id
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
    listing = FactoryGirl.create :listing 
    it "should load new post" do
      Post.load_new(listing).should_not be_nil
    end

    it "should not load new post" do
      Post.load_new(nil).should be_nil
    end
  end
  
end
