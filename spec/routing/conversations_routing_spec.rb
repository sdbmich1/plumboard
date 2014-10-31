require "spec_helper"

describe "routes for Conversations" do

    it "does route to #index" do
      get("/conversations").should route_to("conversations#index")
    end

    it "does route to #create" do
      post("/conversations").should route_to("conversations#create")
    end

    it "does route to #destroy" do
      delete("/conversations/1").should route_to("conversations#destroy", :id => "1")
    end

    it "does route to #remove" do
      put("/conversations/1/remove").should route_to("conversations#remove", :id => "1")
    end

    it "does route to #reply" do
      post("/conversations/reply").should route_to("conversations#reply")
    end

    it "does route to #show" do 
      get("/conversations/1").should route_to("conversations#show", :id => "1")
    end

    it "does not expose a new conversation route" do
      get("/conversations/new").should_not route_to("conversations#new")
    end

    it "does not route to #edit" do
      get("/conversations/1/edit").should_not route_to("conversations#edit", :id => "1")
    end

    it "does not expose an update conversation route" do
      put("/conversations/1").should_not route_to("conversations#update", :id => "1")
    end
end

