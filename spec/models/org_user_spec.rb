require 'spec_helper'

describe OrgUser do
  before(:each) do
    @organization = FactoryGirl.build(:organization)
    @user = FactoryGirl.build(:user)
    @org_user = @organization.org_users.build(:user_id=>@user.id)
  end

  describe "org users" do
    it "should have a user attribute" do
      @org_user.should respond_to(:user)
    end

    it "should have an organization attribute" do
      @org_user.should respond_to(:organization)
    end
  end

  describe "validations" do
    it "should require an org_id" do
      @org_user.org_id = nil
      @org_user.should_not be_valid
    end

    it "should require a user_id" do
      @org_user.user_id = nil
      @org_user.should_not be_valid
    end
  end
end
