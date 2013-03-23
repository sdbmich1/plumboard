require "spec_helper"

describe ListingsController do
  describe "routing" do

    it "routes to #index" do
      get("/listings").should route_to("listings#index")
    end

    it "routes to #show" do
      get("/listings/1").should route_to("listings#show", :id => "1")
    end

    it "routes to #destroy" do
      delete("/listings/1").should route_to("listings#destroy", :id => "1")
    end

    it "routes to #seller" do
      get("/listings/seller").should route_to("listings#seller")
    end

    it "does not expose a new listing route" do
      get("/listings/new").should_not route_to("listings#new")
    end
  end
end

