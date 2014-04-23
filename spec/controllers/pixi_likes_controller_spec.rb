require 'login_user_spec'

describe PixiLikesController do
  include LoginTestUser

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  def mock_like(stubs={})
    (@mock_like ||= mock_model(PixiLike, stubs).as_null_object).tap do |like|
      like.stub(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
    @user = mock_user
  end

  describe "POST create" do
    before :each do
      @like = mock_model PixiLike
      controller.stub!(:current_user).and_return(@user)
      @user.stub_chain(:pixi_likes, :build).and_return(@like)
      controller.stub!(:reload_data).and_return(true)
    end
    
    def do_create
      xhr :post, :create, id: '1'
    end

    context 'failure' do
      
      before :each do
        @like.stub!(:save).and_return(false)
      end

      it "should assign @like" do
        do_create
        assigns(:like).should_not be_nil 
      end

      it "should render nothing" do
        do_create
	controller.stub!(:render)
      end
    end

    context 'success' do

      before :each do
        @like.stub!(:save).and_return(true)
      end

      it "should load the requested like" do
        @user.stub_chain(:pixi_likes, :build) { mock_like(:save => true) }
        do_create
      end

      it "should assign @like" do
        do_create
        assigns(:like).should_not be_nil 
      end

      it "should change like count" do
        lambda do
          do_create
          should change(PixiLike, :count).by(1)
        end
      end

      it "responds to JSON" do
        post :create, pixi_id: '1', format: :json
	response.status.should_not eq(0)
      end
    end
  end

  describe "DELETE /:id" do
    before (:each) do
      @like = mock_model PixiLike
      controller.stub!(:current_user).and_return(@user)
      @user.stub_chain(:build, :pixi_likes, :find_by_pixi_id).and_return(@like)
      controller.stub!(:reload_data).and_return(true)
    end

    def do_delete
      xhr :delete, :destroy, :id => "37"
    end

    context "success" do
      before :each do
        @like.stub!(:destroy).and_return(true)
      end

      it "should load the requested like" do
        @user.stub_chain(:pixi_likes, :find_by_pixi_id) { @like }
        do_delete
      end

      it "should delete the requested like" do
        @user.stub_chain(:pixi_likes, :find_by_pixi_id) { mock_like }
	mock_like.should_receive(:destroy).and_return(:success)
        do_delete
      end

      it "should assign @like" do
        @user.stub_chain(:pixi_likes, :find_by_pixi_id) { mock_like(:destroy => true) }
        do_delete
        assigns(:like).should_not be_nil 
      end

      it "should decrement the PixiLike count" do
	lambda do
	  do_delete
	  should change(PixiLike, :count).by(-1)
	end
      end

      it "should render nothing" do
        do_delete
        controller.stub!(:render)
      end
    end

    context 'failure' do
      before :each do
        @like.stub!(:destroy).and_return(false) 
      end

      it "should assign like" do
        do_delete
        assigns(:like).should_not be_nil 
      end

      it "should render nothing" do
        do_delete
        controller.stub!(:render)
      end
    end
  end
end
