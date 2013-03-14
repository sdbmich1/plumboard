require "spec_helper"

describe "routes for Pictures" do
  it "routes /system/pictures to the pictures controller" do
    expect( :get => "/system/pictures/photos/1/original/Guitar_1.jpg" ).to route_to(:controller=>"pictures", :action=>"asset",
    	:class =>"pictures", :attachment =>"photos", :id =>"1", :style =>"original", :filename =>"Guitar_1", :format=>"jpg")
  end
end
