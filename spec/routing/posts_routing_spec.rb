require "spec_helper"

describe "routes for Posts" do

    it "does route to #create" do
      post("/posts").should route_to("posts#create")
    end

    it "does route to #destroy" do
      delete("/posts/1").should route_to("posts#destroy", :id => "1")
    end

    it "does route to #remove" do
      get("/posts/1/remove").should route_to("posts#remove", :id => "1")
    end

    it "does route to #mark_read" do
      put("/posts/1/mark_read").should route_to("posts#mark_read", :id => "1")
    end

    it "does route to #unread" do
      get("/posts/unread").should route_to("posts#unread")
    end

    it "does route to #mark" do
      get("/posts/mark").should route_to("posts#mark")
    end

    it "does not route to #show" do 
      get("/posts/1").should_not route_to("posts#show", :id => "1")
    end

    it "does not expose a new post route" do
      get("/posts/new").should_not route_to("posts#new")
    end

    it "does not expose a index post route" do
      get("/posts/index").should_not route_to("posts#index")
    end

    it "does not route to #edit" do
      get("/posts/1/edit").should_not route_to("posts#edit", :id => "1")
    end

    it "does not expose an update post route" do
      put("/posts/1").should_not route_to("posts#update", :id => "1")
    end
end

