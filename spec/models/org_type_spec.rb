require 'spec_helper'

describe OrgType do

  before(:each) do
    @org_type = build(:org_type)
  end
  
  subject { @org_type }

  it { should respond_to(:description) }
  it { should respond_to(:code) }
  it { should respond_to(:hide) }
    it { should respond_to(:status) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:code) }
  it { should validate_presence_of(:hide) }
  it { should validate_presence_of(:status) }

  describe "active org_types" do
    before { create(:org_type, status: 'active') }
    it { OrgType.active.should_not be_nil }
  end

  describe "inactive org_types" do
    before { create(:org_type, status: 'inactive') }
    it { OrgType.active.should be_empty }
  end

  describe "hidden org_types" do
    before { create(:org_type, hide: 'yes') }
    it { OrgType.unhidden.should be_empty }
  end

  describe "unhidden org_types" do
    before { create(:org_type, hide: 'no') }
    it { OrgType.unhidden.should_not be_nil }
  end

  describe 'nice_descr' do
    it { @org_type.nice_descr.should == @org_type.description.titleize }

    it 'does not return titleized description' do
      @org_type.description = nil
      @org_type.nice_descr.should be_nil
    end
  end
end
