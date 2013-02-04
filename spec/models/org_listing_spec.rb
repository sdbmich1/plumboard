require 'spec_helper'

describe OrgListing do
  before(:each) do
    @organization = FactoryGirl.build(:organization)
    @org_listing = @organization.org_listings.build(:listing_id=>1)
  end

  describe "org listings" do
    it "should have a listing attribute" do
      @org_listing.should respond_to(:listing)
    end

    it "should have an organization attribute" do
      @org_listing.should respond_to(:organization)
    end
  end

  describe "validations" do
    it "should require an org_id" do
      @org_listing.org_id = nil
      @org_listing.should_not be_valid
    end

    it "should require a listing_id" do
      @org_listing.listing_id = nil
      @org_listing.should_not be_valid
    end
  end
end
