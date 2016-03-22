require "spec_helper"

describe SitesController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/sites")).to route_to("sites#index")
    end

    it "routes to #new" do
      expect(get("/sites/new")).to route_to("sites#new")
    end

    it "routes to #create" do
      expect(post("/sites")).to route_to("sites#create")
    end

    it "routes to #show" do
      expect(get("/sites/1")).to route_to("sites#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/sites/1/edit")).to route_to("sites#edit", :id => "1")
    end

    it "routes to #update" do
      expect(put("/sites/1")).to route_to("sites#update", :id => "1")
    end

    it "does route to #destroy" do
      expect(delete("/sites/1")).not_to route_to("sites#destroy", :id => "1")
    end
  end
end

