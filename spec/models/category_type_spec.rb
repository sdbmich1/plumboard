require 'spec_helper'

describe CategoryType do

  before :each do
    @category_type = FactoryGirl.build(:category_type)
  end

  subject { @category_type}

  it { should respond_to(:code)}
  it { should respond_to(:status)}
  it { should respond_to(:hide)}
  it { should validate_presence_of(:code)}
  it { should validate_presence_of(:status)}
  it { should validate_presence_of(:hide)}
  it { should have_many(:categories).with_foreign_key('category_type_code')}

  describe "active category_types" do
    before {create(:category_type)}
    it {CategoryType.active.should_not be_nil}
  end

  describe "inactive category_types" do
    before {create(:inactive_category_type)}
    it {CategoryType.active.should be_empty}
  end
end
