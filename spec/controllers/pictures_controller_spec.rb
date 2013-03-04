require 'spec_helper'

describe PicturesController do

  describe 'GET /system' do
    before :each do
      File.stub!(:new).with(Rails.root + '/spec/fixtures/photo.jpg').and_return(@file_name)
      @picture = mock_model Picture
      Picture.stub!(:find).and_return( @picture )
      @picture.stub_chain(:photo, :path).with(@file_name).and_return( @picture )
    end

    def do_get
      get :asset, use_route: "/system/pictures/photos/1/original/Guitar_1.jpg", :style => 'original',
      		class: 'pictures', id: 1, filename: 'Guitar_1.jpg', attachment: 'photos'
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

    it "asset action should render nothing" do
      do_get
      controller.should_receive(:send_file).with(@picture)
      controller.stub!(:render)
    end
  end
end
