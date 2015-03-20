require 'spec_helper'

describe FulfillmentType do
  before(:each) do
    @fulfillment_type = build(:fulfillment_type)
  end

  subject { @fulfillment_type }

  it { should respond_to(:description) }
  it { should respond_to(:code) }
  it { should respond_to(:hide) }
  it { should respond_to(:status) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:code) }
  it { should validate_presence_of(:hide) }
  it { should validate_presence_of(:status) }

  describe "active fulfillment_types" do
    before { create(:fulfillment_type, status: 'active') }
    it { FulfillmentType.active.should_not be_nil }
  end

  describe "inactive fulfillment_types" do
    before { create(:fulfillment_type, status: 'inactive') }
    it { FulfillmentType.active.should be_empty }
  end

  describe "hidden fulfillment_types" do
    before { create(:fulfillment_type, hide: 'yes') }
    it { FulfillmentType.unhidden.should be_empty }
  end

  describe "unhidden fulfillment_types" do
    before { create(:fulfillment_type, hide: 'no') }
    it { FulfillmentType.unhidden.should_not be_nil }
  end

  describe 'nice_descr' do
    it { @fulfillment_type.nice_descr.should == @fulfillment_type.description.titleize }

    it 'does not return titleized description' do
      @fulfillment_type.description = nil
      @fulfillment_type.nice_descr.should be_nil
    end
  end
end
