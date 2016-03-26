require "spec_helper"

describe "routes for Settings" do

  it "does route to #index" do
    expect(get("/settings")).to route_to("settings#index")
  end

  it "does not route to #create" do
    expect(post("/settings")).not_to route_to("settings#create")
  end

  it "does not expose a new setting route" do
    expect(get("/settings/new")).not_to route_to("settings#new")
  end

  it "does not route to #edit" do
    expect(get("/settings/1/edit")).not_to route_to("settings#edit", :id => "1")
  end

  it "does not expose an update setting route" do
    expect(put("/settings/1")).not_to route_to("settings#update", :id => "1")
  end

  it "does not route to #destroy" do
    expect(delete("/settings/1")).not_to route_to("settings#destroy", :id => "1")
  end

  it "does not route to #show" do 
    expect(get("/settings/1")).not_to route_to("settings#show", :id => "1")
  end

  it "routes /settings/contact the settings controller" do
    expect( :get => "/settings/contact" ).to route_to(:controller=>"settings", :action=>"contact")
  end

  it "routes /settings/password the settings controller" do
    expect( :get => "/settings/password" ).to route_to(:controller=>"settings", :action=>"password")
  end

  it "routes /settings/details the settings controller" do
    expect( :get => "/settings/details" ).to route_to(:controller=>"settings", :action=>"details")
  end
end
