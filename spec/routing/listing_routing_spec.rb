require "spec_helper"

describe ListingsController do
  describe "routing" do

    it "routes to #index" do
      get("/listings").should route_to("listings#index")
    end

    it "routes to #show" do
      get("/listings/1").should route_to("listings#show", :id => "1")
    end

    it "routes to #seller" do
      get("/listings/seller").should route_to("listings#seller")
    end

    it "routes to #invoiced" do
      get("/listings/invoiced").should route_to("listings#invoiced")
    end

    it "routes to #repost" do
      put("/listings/1/repost").should route_to("listings#repost", :id => "1")
    end

    it "routes to #update" do
      put("/listings/1").should route_to("listings#update", :id => "1")
    end

    it "does route to #destroy" do
      delete("/listings/1").should route_to("listings#destroy", :id => "1")
    end

    it "does not expose a new listing route" do
      get("/listings/new").should_not route_to("listings#new")
    end

    it "does not expose a create listing route" do
      post("/listings/create").should_not route_to("listings#create")
    end

    it "does not route to #edit" do
      get("/listings/1/edit").should_not route_to("listings#edit", :id => "1")
    end
  end
end

