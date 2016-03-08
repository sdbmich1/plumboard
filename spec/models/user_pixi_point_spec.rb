require 'spec_helper'

describe UserPixiPoint do
  before(:each) do
    @pixi_point = FactoryGirl.build(:pixi_point)
    @user = FactoryGirl.build(:pixi_user)
    @user_pixi_point = @user.user_pixi_points.build code: @pixi_point.code
  end

  subject { @user_pixi_point }

  it { is_expected.to respond_to(:user) }
  it { is_expected.to respond_to(:pixi_point) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:code) }

  describe "validations" do
    it "should require a code" do
      @user_pixi_point.code = nil
      expect(@user_pixi_point).not_to be_valid
    end

    it "should require a user_id" do
      @user_pixi_point.user_id = nil
      expect(@user_pixi_point).not_to be_valid
    end
  end
end
