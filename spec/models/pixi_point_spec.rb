require 'spec_helper'

describe PixiPoint do
  before(:each) do
    @pixi_point = FactoryGirl.create :pixi_point
  end
   
  subject { @pixi_point }

  it { is_expected.to respond_to(:category_name) }
  it { is_expected.to respond_to(:action_name) }
  it { is_expected.to respond_to(:value) }
  it { is_expected.to respond_to(:code) } 
  it { is_expected.to respond_to(:user_pixi_points) } 
end
