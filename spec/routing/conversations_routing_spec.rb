require "spec_helper"

describe "routes for Conversations" do

    it "does route to #index" do
      expect(get("/conversations")).to route_to("conversations#index")
    end

    it "does route to #create" do
      expect(post("/conversations")).to route_to("conversations#create")
    end

    it "does route to #destroy" do
      expect(delete("/conversations/1")).to route_to("conversations#destroy", :id => "1")
    end

    it "does route to #remove" do
      expect(put("/conversations/1/remove")).to route_to("conversations#remove", :id => "1")
    end

    it "does route to #reply" do
      expect(post("/conversations/reply")).to route_to("conversations#reply")
    end

    it "does route to #show" do 
      expect(get("/conversations/1")).to route_to("conversations#show", :id => "1")
    end

    it "does not expose a new conversation route" do
      expect(get("/conversations/new")).not_to route_to("conversations#new")
    end

    it "does not route to #edit" do
      expect(get("/conversations/1/edit")).not_to route_to("conversations#edit", :id => "1")
    end

    it "does expose an update conversation route" do
      expect(put("/conversations/1")).to route_to("conversations#update", :id => "1")
    end
end

