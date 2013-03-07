require 'spec_helper'

describe PicturesController do

  describe 'GET /system' do
    before :each do
      @picture = mock_model Picture
      Picture.stub!(:find).and_return( @picture )
      @picture.stub_chain(:photo, :path, :intern).and_return( @picture )
      controller.stub_chain(:send_file, :style).with(@picture).and_return(:success)
      controller.stub!(:style).and_return('original')
    end

    def do_get
      get :asset, use_route: "/system/pictures/photos/1/original/Guitar_1.jpg", :params => {id: '1', 
      		 "style" => 'original', "filename" => 'Guitar_1.jpg' }
    end

    it "should load picture asset" do
      do_get
      response.should be_success
    end

    it "should load the requested picture" do
      Picture.stub(:find).with('1').and_return(@picture)
    end

    it "should assign @picture" do
      do_get
      assigns(:picture).should_not be_nil
    end

    it "should receive send file" do
      controller.should_receive(:send_file).and_return(:success) 
      do_get
    end

    it "asset action should render nothing" do
      do_get
      controller.stub!(:render)
    end
  end
end
