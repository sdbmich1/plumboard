require "spec_helper"

describe "routes for Pictures" do
  it "routes /system/pictures to the pictures controller" do
    expect( :get => "/system/pictures/photos/1/original/Guitar_1.jpg" ).to route_to(:controller=>"pictures", :action=>"asset",
    	:class =>"pictures", :attachment =>"photos", :id =>"1", :style =>"original", :filename =>"Guitar_1", :format=>"jpg")
  end

  it "does route to #destroy" do
    expect(delete("/pictures/1")).to route_to("pictures#destroy", :id => "1")
  end

    it "does not route to #index" do
      expect(get("/pictures")).not_to route_to("pictures#index")
    end

    it "does not route to #show" do
      expect(get("/pictures/1")).not_to route_to("pictures#show", :id => "1")
    end

    it "does not expose a new picture route" do
      expect(get("/pictures/new")).not_to route_to("pictures#new")
    end

    it "does not expose a create picture route" do
      expect(post("/pictures/create")).not_to route_to("pictures#create")
    end

    it "does not expose a update picture route" do
      expect(put("/pictures/1")).not_to route_to("pictures#update", :id => "1")
    end

    it "does not route to #edit" do
      expect(get("/pictures/1/edit")).not_to route_to("pictures#edit", :id => "1")
    end
end
