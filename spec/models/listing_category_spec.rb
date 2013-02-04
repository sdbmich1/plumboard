require 'spec_helper'

describe ListingCategory do
  before(:each) do
    @listing = FactoryGirl.build(:listing)
    @listing_category = @listing.listing_categories.build(:category_id=>1)
  end

  describe "listing categories" do
    it "should have a listing attribute" do
      @listing_category.should respond_to(:listing)
    end

    it "should have a category  attribute" do
      @listing_category.should respond_to(:category)
    end
  end

  describe "validations" do
    it "should require a category_id" do
      @listing_category.category_id = nil
      @listing_category.should_not be_valid 
    end

    it "should require a listing_id" do
      @listing_category.listing_id = nil
      @listing_category.should_not be_valid
    end
  end

end
