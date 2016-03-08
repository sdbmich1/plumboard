require 'spec_helper'

describe StatusType do
  before(:each) do
    @status_type = build(:status_type)
  end

  subject { @status_type }
  it { is_expected.to respond_to(:hide) }
  it { is_expected.to respond_to(:code) }
  it { is_expected.to validate_presence_of(:code) }

  describe "active status_types" do
    before { create(:status_type, code: 'active') }
    it { expect(StatusType.active).not_to be_nil } 
  end

  describe "inactive status_types" do
    before { create(:status_type, code: 'inactive') }
    it { expect(StatusType.active).to be_empty } 
  end

  describe "hidden status_types" do
    before { create(:status_type, code: 'active', hide: 'yes') }
    it { expect(StatusType.unhidden).to be_empty } 
  end

  describe "unhidden status_types" do
    before { create(:status_type, code: 'active') }
    it { expect(StatusType.unhidden).not_to be_nil } 
  end

  describe 'code_title' do
    it { expect(@status_type.code_title).to eq(@status_type.code.titleize) }

    it 'does not return titleized code' do
      @status_type.code = nil
      expect(@status_type.code_title).to be_nil
    end
  end
end
