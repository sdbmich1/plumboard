require 'spec_helper'

describe Category do
  before(:each) do
    @category = FactoryGirl.build(:category)
  end

  subject { @category }

  it { should respond_to(:name) }
  it { should respond_to(:status) }
  it { should respond_to(:category_type) }
  it { should respond_to(:pixi_type) }
  it { should respond_to(:listings) }
  it { should respond_to(:temp_listings) }

  describe "when name is empty" do
    before { @category.name = "" }
    it { should_not be_valid }
  end

  describe "when name is entered" do
    before { @category.name = "gigs" }
    it { @category.name.should == "gigs" }
  end

  describe "when status is empty" do
    before { @category.status = "" }
    it { should_not be_valid }
  end

  describe "when status is entered" do
    before { @category.status = "active" }
    it { @category.status.should == "active" }
  end

  describe "when category_type is empty" do
    before { @category.category_type = "" }
    it { should_not be_valid }
  end

  describe "when category_type is entered" do
    before { @category.category_type = "gigs" }
    it { @category.category_type.should == "gigs" }
  end

  describe "should include active categories" do
    category = Category.create(:status => "active")
    it { Category.active.should_not be_nil } 
  end

  describe "should not include inactive categories" do
    category = Category.create(:status => "inactive")
    it { Category.active.should_not include(category) }
  end

  describe 'premium?' do
    it 'should return true' do
      @category.pixi_type = 'premium'
      @category.premium?.should be_true
    end

    it 'should not return true' do
      @category.pixi_type = nil
      @category.premium?.should_not be_true
    end
  end

end
