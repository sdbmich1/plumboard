require 'spec_helper'

describe Post do
  before(:each) do
    @post = FactoryGirl.build(:post) 
  end
   
  subject { @post }

  it { should respond_to(:content) }
  it { should respond_to(:listing_id) }
  it { should respond_to(:user_id) }

  it { should respond_to(:user) }
  it { should respond_to(:listing) }

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

end
