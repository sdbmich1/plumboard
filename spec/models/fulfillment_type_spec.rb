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
  it { should have_many(:listings).with_foreign_key('fulfillment_type_code') }
  it { should have_many(:temp_listings).with_foreign_key('fulfillment_type_code') }

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

  describe "buyer_options" do
    it "does not include 'All'" do
      fulfillment_type = create :fulfillment_type, code: 'A'
      expect(FulfillmentType.buyer_options).not_to include fulfillment_type
    end

    it "does not include hidden fulfillment types" do
      fulfillment_type = create :fulfillment_type, hide: 'yes'
      expect(FulfillmentType.buyer_options).not_to include fulfillment_type
    end

    it "includes other fulfillment types" do
      fulfillment_type = create :fulfillment_type, code: 'SHP'
      expect(FulfillmentType.buyer_options).to include fulfillment_type
    end
  end
end
