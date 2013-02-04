require 'spec_helper'

describe Post do
  before(:each) do
    @user = FactoryGirl.build(:user) 
    @post = @user.posts.build(:listing_id=>1)
  end

  it "should have an user method" do
    @post.should respond_to(:user)
  end

  it "should have a listings method" do
    @post.should respond_to(:listing)
  end

  describe "when content is empty" do
    before { @post.content = "" }
    it { should_not be_valid }
  end

end
