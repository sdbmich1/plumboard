require 'spec_helper'

describe Category do
  before(:each) do
    @category = FactoryGirl.build(:category)
  end

  subject { @category }

  describe "listing categories" do
    context "should have a listing category attribute" do
      it { should respond_to(:listing_categories) }
    end
  end

  describe "should include active categories" do
    category = Category.create(:status => "active")
    it { Category.active.should_not be_nil } 
  end

  describe "should not include inactive categories" do
    category = Category.create(:status => "inactive")
    it { Category.active.should_not include(category) }
  end
end
