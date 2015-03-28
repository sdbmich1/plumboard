require "spec_helper"

describe "routes for Searches" do
  it "routes /biz/:route to the searches controller" do
    expect( :get => "/biz/test" ).to route_to(:controller=>"searches", :action=>"biz", :search =>"test")
  end

  it "routes /mbr/:route to the searches controller" do
    expect( :get => "/mbr/test" ).to route_to(:controller=>"searches", :action=>"biz", :search =>"test")
  end

  it "routes /careers the searches controller" do
    expect( :get => "/careers" ).to route_to(:controller=>"searches", :action=>"jobs")
  end

  it "does route to #destroy" do
    delete("/searches/1").should_not route_to("searches#destroy", :id => "1")
  end

  it "routes to #index" do
    get("/searches").should route_to("searches#index")
  end

  it "does not route to #show" do
    get("/searches/1").should_not route_to("searches#show", :id => "1")
  end

  it "does not expose a new route" do
    get("/searches/new").should_not route_to("searches#new")
  end

  it "does not expose a create route" do
    post("/searches/create").should_not route_to("searches#create")
  end

  it "does not expose a update route" do
    put("/searches/1").should_not route_to("searches#update", :id => "1")
  end

  it "does not route to #edit" do
    get("/searches/1/edit").should_not route_to("searches#edit", :id => "1")
  end
end
