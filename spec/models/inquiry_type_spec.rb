require 'spec_helper'

describe InquiryType do
  before(:each) do
    @inquiry_type = FactoryGirl.build(:inquiry_type)
  end

  subject { @inquiry_type }

  it { is_expected.to respond_to(:subject) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:contact_type) }
  it { is_expected.to respond_to(:code) }
  it { is_expected.to validate_presence_of(:subject) }
  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:contact_type) }
  it { is_expected.to have_many(:inquiries).with_foreign_key('code') }

  describe "active inquiry_types" do
    before { FactoryGirl.create(:inquiry_type) }
    it { expect(InquiryType.active).not_to be_nil } 
  end

  describe "inactive inquiry_types" do
    before { FactoryGirl.create(:inquiry_type, status: 'inactive') }
    it { expect(InquiryType.active).to be_empty } 
  end

  describe "support inquiry_types" do
    before { FactoryGirl.create(:inquiry_type, contact_type: 'support') }
    it { expect(InquiryType.support).not_to be_nil } 
  end

  describe "no support inquiry_types" do
    before { FactoryGirl.create(:inquiry_type, contact_type: 'inactive') }
    it { expect(InquiryType.support).to be_empty } 
  end

  describe "general inquiry_types" do
    before { FactoryGirl.create(:inquiry_type, contact_type: 'inquiry') }
    it { expect(InquiryType.general).not_to be_nil } 
  end

  describe "no general inquiry_types" do
    before { FactoryGirl.create(:inquiry_type, contact_type: 'inactive') }
    it { expect(InquiryType.general).to be_empty } 
  end
end
