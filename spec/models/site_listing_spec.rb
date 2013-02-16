require 'spec_helper'

describe SiteListing do
  before(:each) do
    @site = FactoryGirl.build(:site)
    @site_listing = @site.site_listings.build(:listing_id=>1)
  end

  describe "site listings" do
    it "should have a listing attribute" do
      @site_listing.should respond_to(:listing)
    end

    it "should have an site attribute" do
      @site_listing.should respond_to(:site)
    end
  end

  describe "validations" do
    it "should require an site_id" do
      @site_listing.site_id = nil
      @site_listing.should_not be_valid
    end

    it "should require a listing_id" do
      @site_listing.listing_id = nil
      @site_listing.should_not be_valid
    end
  end
end
