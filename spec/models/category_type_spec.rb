require 'spec_helper'

describe CategoryType do

  before :each do
    @category_type = FactoryGirl.build(:category_type)
  end

  subject { @category_type}

  it { is_expected.to respond_to(:code)}
  it { is_expected.to respond_to(:status)}
  it { is_expected.to respond_to(:hide)}
  it { is_expected.to validate_presence_of(:code)}
  it { is_expected.to validate_presence_of(:status)}
  it { is_expected.to validate_presence_of(:hide)}
  it { is_expected.to have_many(:categories).with_foreign_key('category_type_code')}

  describe "active category_types" do
    before {create(:category_type)}
    it {expect(CategoryType.active).not_to be_nil}
  end

  describe "inactive category_types" do
    before {create(:inactive_category_type)}
    it {expect(CategoryType.active).to be_empty}
  end
end
