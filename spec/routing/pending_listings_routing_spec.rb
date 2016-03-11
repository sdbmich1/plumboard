require "spec_helper"

describe PendingListingsController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/pending_listings")).to route_to("pending_listings#index")
    end

    it "routes to #show" do
      expect(get("/pending_listings/1")).to route_to("pending_listings#show", :id => "1")
    end

    it "routes to #approve" do
      expect(put("/pending_listings/1/approve")).to route_to("pending_listings#approve", :id => "1")
    end

    it "routes to #deny" do
      expect(put("/pending_listings/1/deny")).to route_to("pending_listings#deny", :id => "1")
    end

    it "should not route to #edit" do
      expect(get("/pending_listings/1/edit")).not_to route_to("pending_listings#edit", :id => "1")
    end

    it "should not route to #create" do
      expect(post("/pending_listings")).not_to route_to("pending_listings#create")
    end

    it "should not route to #update" do
      expect(put("/pending_listings/1")).not_to route_to("pending_listings#update", :id => "1")
    end

    it "should not route to #destroy" do
      expect(delete("/pending_listings/1")).not_to route_to("pending_listings#destroy", :id => "1")
    end

    it "does not expose a new pending_listing route" do
      expect(get("/pending_listings/new")).not_to route_to("pending_listings#new")
    end
  end
end

