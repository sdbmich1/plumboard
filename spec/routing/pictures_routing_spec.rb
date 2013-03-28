require "spec_helper"

describe "routes for Pictures" do
  it "routes /system/pictures to the pictures controller" do
    expect( :get => "/system/pictures/photos/1/original/Guitar_1.jpg" ).to route_to(:controller=>"pictures", :action=>"asset",
    	:class =>"pictures", :attachment =>"photos", :id =>"1", :style =>"original", :filename =>"Guitar_1", :format=>"jpg")
  end

  it "does route to #destroy" do
    delete("/pictures/1").should route_to("pictures#destroy", :id => "1")
  end

    it "does not route to #index" do
      get("/pictures").should_not route_to("pictures#index")
    end

    it "does not route to #show" do
      get("/pictures/1").should_not route_to("pictures#show", :id => "1")
    end

    it "does not expose a new picture route" do
      get("/pictures/new").should_not route_to("pictures#new")
    end

    it "does not expose a create picture route" do
      post("/pictures/create").should_not route_to("pictures#create")
    end

    it "does not expose a update picture route" do
      put("/pictures/1").should_not route_to("pictures#update", :id => "1")
    end

    it "does not route to #edit" do
      get("/pictures/1/edit").should_not route_to("pictures#edit", :id => "1")
    end
end
