require 'spec_helper'

describe CurrencyType do
  
  before(:each) do
    @currency_type = build(:currency_type)
  end
  
  subject { @currency_type }

  it { should respond_to(:description) }
  it { should respond_to(:code) }
  it { should respond_to(:hide) }
  it { should respond_to(:status) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:code) }
  it { should validate_presence_of(:hide) }
  it { should validate_presence_of(:status) }

  describe "active currency_types" do
    before { create(:currency_type, status: 'active') }
    it { CurrencyType.active.should_not be_nil }
  end

  describe "inactive currency_types" do
    before { create(:currency_type, status: 'inactive') }
    it { CurrencyType.active.should be_empty }
  end

  describe "hidden currency_types" do
    before { create(:currency_type, hide: 'yes') }
    it { CurrencyType.unhidden.should be_empty }
  end

  describe "unhidden currency_types" do
    before { create(:currency_type, hide: 'no') }
    it { CurrencyType.unhidden.should_not be_nil }
  end

  describe 'nice_descr' do
    it { @currency_type.nice_descr.should == @currency_type.description.titleize }

    it 'does not return titleized description' do
      @currency_type.description = nil
      @currency_type.nice_descr.should be_nil
    end
  end
end