require "spec_helper"

describe PendingListingsController do
  describe "routing" do

    it "routes to #index" do
      get("/pending_listings").should route_to("pending_listings#index")
    end

    it "routes to #show" do
      get("/pending_listings/1").should route_to("pending_listings#show", :id => "1")
    end

    it "routes to #approve" do
      put("/pending_listings/1/approve").should route_to("pending_listings#approve", :id => "1")
    end

    it "routes to #deny" do
      put("/pending_listings/1/deny").should route_to("pending_listings#deny", :id => "1")
    end
  end
end

