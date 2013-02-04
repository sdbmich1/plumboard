require 'spec_helper'

describe Category do
  before(:each) do
    @category = FactoryGirl.build(:category)
  end

  describe "listing categories" do
    it "should have a listing category attribute" do
      @category.should respond_to(:listing_categories)
    end
  end

  describe "should include active categories" do
    category = Category.create(:status => "active")
    it { Category.active.should include(category) }
  end

  describe "should not include inactive categories" do
    category = Category.create(:status => "inactive")
    it { Category.active.should_not include(category) }
  end
end
