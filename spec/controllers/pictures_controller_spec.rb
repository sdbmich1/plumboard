require 'spec_helper'

describe PicturesController do

  describe 'GET /system' do
    before :each do
      @picture = mock_model Picture
      Picture.stub!(:find).and_return( @picture )
    end

    def do_get
      get "/system/pictures/photos/1/original/Guitar_1.jpg", use_route: 'pictures/asset' 
    end

    it "should load picture asset" do
      do_get
      response.should be_success
    end

    it "should load the requested picture" do
      Picture.stub(:find).with('1').and_return(@picture)
      do_get
    end

    it "asset action should render nothing" do
      do_get
      controller.should_receive(:send_file).and_return{controller.render :nothing => true}
    end
  end
end
