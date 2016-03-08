require "spec_helper"

describe TempListingsController do
  describe "routing" do

    it "routes to #new" do
      expect(get("/temp_listings/new")).to route_to("temp_listings#new")
    end

    it "routes to #show" do
      expect(get("/temp_listings/1")).to route_to("temp_listings#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/temp_listings/1/edit")).to route_to("temp_listings#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/temp_listings")).to route_to("temp_listings#create")
    end

    it "routes to #update" do
      expect(put("/temp_listings/1")).to route_to("temp_listings#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/temp_listings/1")).to route_to("temp_listings#destroy", :id => "1")
    end

    it "routes to #resubmit" do
      expect(put("/temp_listings/1/resubmit")).to route_to("temp_listings#resubmit", :id => "1")
    end

    it "routes to #invoiced" do
      expect(get("/temp_listings/invoiced")).to route_to("temp_listings#invoiced")
    end

    it "routes to #index" do
      expect(get("/temp_listings")).to route_to("temp_listings#index")
    end

  end
end
