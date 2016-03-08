require "spec_helper"

describe "routes for Posts" do

    it "does not route to #create" do
      expect(post("/posts")).not_to route_to("posts#create")
    end

    it "does route to #destroy" do
      expect(delete("/posts/1")).to route_to("posts#destroy", :id => "1")
    end

    it "does route to #remove" do
      expect(get("/posts/1/remove")).to route_to("posts#remove", :id => "1")
    end

    it "does route to #mark_read" do
      expect(put("/posts/1/mark_read")).to route_to("posts#mark_read", :id => "1")
    end

    it "does route to #unread" do
      expect(get("/posts/unread")).to route_to("posts#unread")
    end

    it "does route to #mark" do
      expect(get("/posts/mark")).to route_to("posts#mark")
    end

    it "does not route to #show" do 
      expect(get("/posts/1")).not_to route_to("posts#show", :id => "1")
    end

    it "does not expose a new post route" do
      expect(get("/posts/new")).not_to route_to("posts#new")
    end

    it "does not expose a index post route" do
      expect(get("/posts/index")).not_to route_to("posts#index")
    end

    it "does not route to #edit" do
      expect(get("/posts/1/edit")).not_to route_to("posts#edit", :id => "1")
    end

    it "does not expose an update post route" do
      expect(put("/posts/1")).not_to route_to("posts#update", :id => "1")
    end
end

