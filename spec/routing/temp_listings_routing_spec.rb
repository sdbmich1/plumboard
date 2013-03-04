require "spec_helper"

describe TempListingsController do
  describe "routing" do

    it "routes to #index" do
      get("/temp_listings").should route_to("temp_listings#index")
    end

    it "routes to #new" do
      get("/temp_listings/new").should route_to("temp_listings#new")
    end

    it "routes to #show" do
      get("/temp_listings/1").should route_to("temp_listings#show", :id => "1")
    end

    it "routes to #edit" do
      get("/temp_listings/1/edit").should route_to("temp_listings#edit", :id => "1")
    end

    it "routes to #create" do
      post("/temp_listings").should route_to("temp_listings#create")
    end

    it "routes to #update" do
      put("/temp_listings/1").should route_to("temp_listings#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/temp_listings/1").should route_to("temp_listings#destroy", :id => "1")
    end

  end
end
