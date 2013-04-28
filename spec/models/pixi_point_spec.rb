require 'spec_helper'

describe PixiPoint do
  before(:each) do
    @pixi_point = FactoryGirl.create :pixi_point
  end
   
  subject { @pixi_point }

  it { should respond_to(:category_name) }
  it { should respond_to(:action_name) }
  it { should respond_to(:value) }
  it { should respond_to(:code) } 
  it { should respond_to(:user_pixi_points) } 
end
