require "spec_helper"

describe TransactionsController do
  describe "routing" do

    it "routes to #index" do
      get("/transactions").should route_to("transactions#index")
    end

    it "routes to #show" do
      get("/transactions/1").should route_to("transactions#show", :id => "1")
    end

    it "routes to #edit" do
      get("/transactions/1/edit").should route_to("transactions#edit", :id => "1")
    end

    it "routes to #create" do
      post("/transactions").should route_to("transactions#create")
    end

    it "routes to #update" do
      put("/transactions/1").should route_to("transactions#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/transactions/1").should route_to("transactions#destroy", :id => "1")
    end

    it "routes to #build" do
      get("/transactions/build").should route_to("transactions#build")
    end

    it "routes to #refund" do
      get("/transactions/refund").should route_to("transactions#refund")
    end
  end
end


