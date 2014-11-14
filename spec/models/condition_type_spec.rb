require 'spec_helper'

describe ConditionType do
  before(:each) do
  	@condition_type = build(:condition_type)
  end
  
  subject { @condition_type }

  it { should respond_to(:code) }
  it { should respond_to(:hide) }
  it { should respond_to(:status) }
  it { should validate_presence_of(:code) }
  it { should validate_presence_of(:hide) }
  it { should validate_presence_of(:status) }

  describe "active condition_types" do
    before { create(:condition_type, status: 'active') }
    it { ConditionType.active.should_not be_nil }
  end

    describe "inactive condition_types" do
    before { create(:condition_type, status: 'inactive') }
    it { ConditionType.active.should be_empty }
  end

  describe "hidden condition_types" do
  	before { create(:condition_type, hide: 'yes') }
  	it { ConditionType.unhidden.should be_empty }
  end

  describe "unhidden condition_types" do
  	before { create(:condition_type, hide: 'no') }
  	it { ConditionType.unhidden.should_not be_nil }
  end
end