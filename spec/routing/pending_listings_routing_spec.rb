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

    it "routes to #invoiced" do
      get("/pending_listings/invoiced").should route_to("pending_listings#invoiced")
    end

    it "should not route to #edit" do
      get("/pending_listings/1/edit").should_not route_to("pending_listings#edit", :id => "1")
    end

    it "should not route to #create" do
      post("/pending_listings").should_not route_to("pending_listings#create")
    end

    it "should not route to #update" do
      put("/pending_listings/1").should_not route_to("pending_listings#update", :id => "1")
    end

    it "should not route to #destroy" do
      delete("/pending_listings/1").should_not route_to("pending_listings#destroy", :id => "1")
    end

    it "does not expose a new pending_listing route" do
      get("/pending_listings/new").should_not route_to("pending_listings#new")
    end
  end
end

