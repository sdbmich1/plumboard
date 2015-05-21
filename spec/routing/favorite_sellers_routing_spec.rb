require "spec_helper"

describe "routes for FavoriteSellers" do
  it "routes to #create" do
    post("/favorite_sellers").should route_to("favorite_sellers#create")
  end

  it "routes to #index" do
    get("/favorite_sellers").should route_to("favorite_sellers#index")
  end

  it "routes to #update" do
    put("/favorite_sellers/1").should route_to("favorite_sellers#update", :id => "1")
  end

  it "does not route to #destroy" do
    delete("/favorite_sellers/1").should_not route_to("favorite_sellers#destroy", :id => "1")
  end

  it "does not route to #show" do
    get("/favorite_sellers/1").should_not route_to("favorite_sellers#show", :id => "1")
  end

  it "does not route to #new" do
    get("/favorite_sellers/new").should_not route_to("favorite_sellers#new")
  end

  it "does not route to #edit" do
    get("/favorite_sellers/1/edit").should_not route_to("favorite_sellers#edit")
  end
end

