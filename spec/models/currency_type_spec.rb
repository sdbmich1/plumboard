require 'spec_helper'

describe CurrencyType do
  
  before(:each) do
    @currency_type = build(:currency_type)
  end
  
  subject { @currency_type }

  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:code) }
  it { is_expected.to respond_to(:hide) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:hide) }
  it { is_expected.to validate_presence_of(:status) }

  describe "active currency_types" do
    before { create(:currency_type, status: 'active') }
    it { expect(CurrencyType.active).not_to be_nil }
  end

  describe "inactive currency_types" do
    before { create(:currency_type, status: 'inactive') }
    it { expect(CurrencyType.active).to be_empty }
  end

  describe "hidden currency_types" do
    before { create(:currency_type, hide: 'yes') }
    it { expect(CurrencyType.unhidden).to be_empty }
  end

  describe "unhidden currency_types" do
    before { create(:currency_type, hide: 'no') }
    it { expect(CurrencyType.unhidden).not_to be_nil }
  end

  describe 'nice_descr' do
    it { expect(@currency_type.nice_descr).to eq(@currency_type.description.titleize) }

    it 'does not return titleized description' do
      @currency_type.description = nil
      expect(@currency_type.nice_descr).to be_nil
    end
  end
end