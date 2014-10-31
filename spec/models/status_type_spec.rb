require 'spec_helper'

describe StatusType do
  before(:each) do
    @status_type = build(:status_type)
  end

  subject { @status_type }
  it { should respond_to(:hide) }
  it { should respond_to(:code) }
  it { should validate_presence_of(:code) }

  describe "active status_types" do
    before { create(:status_type, code: 'active') }
    it { StatusType.active.should_not be_nil } 
  end

  describe "inactive status_types" do
    before { create(:status_type, code: 'inactive') }
    it { StatusType.active.should be_empty } 
  end

  describe "hidden status_types" do
    before { create(:status_type, code: 'active', hide: 'yes') }
    it { StatusType.unhidden.should be_empty } 
  end

  describe "unhidden status_types" do
    before { create(:status_type, code: 'active') }
    it { StatusType.unhidden.should_not be_nil } 
  end

  describe 'code_title' do
    it { @status_type.code_title.should == @status_type.code.titleize }

    it 'does not return titleized code' do
      @status_type.code = nil
      @status_type.code_title.should be_nil
    end
  end
end
