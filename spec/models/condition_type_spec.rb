require 'spec_helper'

describe ConditionType do
  before(:each) do
    @condition_type = build(:condition_type)
  end
  
  subject { @condition_type }

  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:code) }
  it { is_expected.to respond_to(:hide) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:hide) }
  it { is_expected.to validate_presence_of(:status) }

  describe "active condition_types" do
    before { create(:condition_type, status: 'active') }
    it { expect(ConditionType.active).not_to be_nil }
  end

  describe "inactive condition_types" do
    before { create(:condition_type, status: 'inactive') }
    it { expect(ConditionType.active).to be_empty }
  end

  describe "hidden condition_types" do
    before { create(:condition_type, hide: 'yes') }
    it { expect(ConditionType.unhidden).to be_empty }
  end

  describe "unhidden condition_types" do
    before { create(:condition_type, hide: 'no') }
    it { expect(ConditionType.unhidden).not_to be_nil }
  end

  describe 'nice_descr' do
    it { expect(@condition_type.nice_descr).to eq(@condition_type.description.titleize) }

    it 'does not return titleized description' do
      @condition_type.description = nil
      expect(@condition_type.nice_descr).to be_nil
    end
  end
end
