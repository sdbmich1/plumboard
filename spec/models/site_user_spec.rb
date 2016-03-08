require 'spec_helper'

describe SiteUser do
  before(:each) do
    @site = FactoryGirl.build(:site)
    @user = FactoryGirl.build(:user)
    @site_user = @site.site_users.build(:user_id=>@user.id)
  end

  describe "site users" do
    it "should have a user attribute" do
      expect(@site_user).to respond_to(:user)
    end

    it "should have an site attribute" do
      expect(@site_user).to respond_to(:site)
    end
  end

  describe "validations" do
    it "should require an site_id" do
      @site_user.site_id = nil
      expect(@site_user).not_to be_valid
    end

    it "should require a user_id" do
      @site_user.user_id = nil
      expect(@site_user).not_to be_valid
    end
  end
end
