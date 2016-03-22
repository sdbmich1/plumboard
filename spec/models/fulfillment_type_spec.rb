require 'spec_helper'

describe FulfillmentType do
  before(:each) do
    @fulfillment_type = build(:fulfillment_type)
  end

  subject { @fulfillment_type }

  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:code) }
  it { is_expected.to respond_to(:hide) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:hide) }
  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to have_many(:listings).with_foreign_key('fulfillment_type_code') }
  it { is_expected.to have_many(:temp_listings).with_foreign_key('fulfillment_type_code') }
  it { is_expected.to have_many(:invoice_details).with_foreign_key('fulfillment_type_code') }
  it { is_expected.to have_many(:preferences).with_foreign_key('fulfillment_type_code') }

  describe "active fulfillment_types" do
    before { create(:fulfillment_type, status: 'active') }
    it { expect(FulfillmentType.active).not_to be_nil }
  end

  describe "inactive fulfillment_types" do
    before { create(:fulfillment_type, status: 'inactive') }
    it { expect(FulfillmentType.active).to be_empty }
  end

  describe "hidden fulfillment_types" do
    before { create(:fulfillment_type, hide: 'yes') }
    it { expect(FulfillmentType.unhidden).to be_empty }
  end

  describe "unhidden fulfillment_types" do
    before { create(:fulfillment_type, hide: 'no') }
    it { expect(FulfillmentType.unhidden).not_to be_nil }
  end

  describe 'nice_descr' do
    it { expect(@fulfillment_type.nice_descr).to eq(@fulfillment_type.description.titleize) }

    it 'does not return titleized description' do
      @fulfillment_type.description = nil
      expect(@fulfillment_type.nice_descr).to be_nil
    end
  end

  describe "buyer_options" do
    before :all do
      @listing = Listing.create FactoryGirl.attributes_for(:listing)
      create :fulfillment_type, code: 'A'
      @listing.update_attribute(:fulfillment_type_code, 'A')
    end

    it "does not include 'All'" do
      expect(FulfillmentType.buyer_options(@listing).pluck(:code)).not_to include 'A'
    end

    it "does not include hidden fulfillment types" do
      fulfillment_type = create :fulfillment_type, hide: 'yes'
      expect(FulfillmentType.buyer_options(@listing)).not_to include fulfillment_type
    end

    it "includes other fulfillment types" do
      create :fulfillment_type, code: 'SHP'
      expect(FulfillmentType.buyer_options(@listing).pluck(:code)).to include 'SHP'
    end

    it "returns P if fulfillment_type_code is nil" do
      @listing.update_attribute(:fulfillment_type_code, nil)
      create :fulfillment_type, code: 'P'
      expect(FulfillmentType.buyer_options(@listing).pluck(:code)).to include 'P'
    end

    it "returns P and SHP if fulfillment_type_code is PS" do
      %w(P SHP PS).each { |c| create :fulfillment_type, code: c }
      @listing.update_attribute(:fulfillment_type_code, 'PS')
      expect(FulfillmentType.buyer_options(@listing).pluck(:code)).to include 'P'
      expect(FulfillmentType.buyer_options(@listing).pluck(:code)).to include 'SHP'
      expect(FulfillmentType.buyer_options(@listing).pluck(:code)).not_to include 'PS'
    end
  end
end
