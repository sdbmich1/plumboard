require 'spec_helper'

describe UserInterest do
  before(:each) do
    @interest = FactoryGirl.build(:interest)
    @user = FactoryGirl.build(:user)
    @user_interest = @interest.user_interests.build(:user_id=>@user.id)
  end

  describe "user interests" do
    it "should have a user attribute" do
      @user_interest.should respond_to(:user)
    end

    it "should have an interest attribute" do
      @user_interest.should respond_to(:interest)
    end
  end

  describe "validations" do
    it "should require an interest_id" do
      @user_interest.interest_id = nil
      @user_interest.should_not be_valid
    end

    it "should require a user_id" do
      @user_interest.user_id = nil
      @user_interest.should_not be_valid
    end
  end

end
