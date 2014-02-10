require 'spec_helper'

describe InquiryType do
  before(:each) do
    @inquiry_type = FactoryGirl.build(:inquiry_type)
  end

  subject { @inquiry_type }

  it { should respond_to(:subject) }
  it { should respond_to(:status) }
  it { should respond_to(:contact_type) }
  it { should respond_to(:code) }
  it { should validate_presence_of(:subject) }
  it { should validate_presence_of(:status) }
  it { should validate_presence_of(:code) }
  it { should validate_presence_of(:contact_type) }
  it { should have_many(:inquiries).with_foreign_key('code') }

  describe "active inquiry_types" do
    before { FactoryGirl.create(:inquiry_type) }
    it { InquiryType.active.should_not be_nil } 
  end

  describe "inactive inquiry_types" do
    before { FactoryGirl.create(:inquiry_type, status: 'inactive') }
    it { InquiryType.active.should be_empty } 
  end

  describe "support inquiry_types" do
    before { FactoryGirl.create(:inquiry_type, contact_type: 'support') }
    it { InquiryType.support.should_not be_nil } 
  end

  describe "no support inquiry_types" do
    before { FactoryGirl.create(:inquiry_type, contact_type: 'inactive') }
    it { InquiryType.support.should be_empty } 
  end

  describe "general inquiry_types" do
    before { FactoryGirl.create(:inquiry_type, contact_type: 'inquiry') }
    it { InquiryType.general.should_not be_nil } 
  end

  describe "no general inquiry_types" do
    before { FactoryGirl.create(:inquiry_type, contact_type: 'inactive') }
    it { InquiryType.general.should be_empty } 
  end
end
