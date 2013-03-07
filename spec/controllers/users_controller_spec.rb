require 'login_user_spec'

describe UsersController do
  include LoginTestUser

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
    @user = mock_user
  end

  describe 'GET index' do
    before(:each) do
      @users = mock("users")
      User.stub!(:all).and_return(@users)
    end

    def do_get
      get :index
    end

    it "renders the :index view" do
      do_get
      response.should render_template :index
    end

    it "should assign @users" do
      User.should_receive(:all).and_return(@users)
      do_get 
      assigns(:users).should_not be_nil
    end
  end

  describe 'GET show/:id' do
    before :each do
      @photo = stub_model(Picture)
      User.stub!(:find).and_return( @user )
      @user.stub!(:pictures).and_return( @photo )
    end

    def do_get
      get :show, :id => @user
    end

    it "should show the requested user" do
      do_get
      response.should be_success
    end

    it "should load the requested user" do
      User.stub(:find).with(@user.id).and_return(@user)
      do_get
    end

    it "should assign @user" do
      do_get
      assigns(:user).should_not be_nil
    end

    it "should assign @photo" do
      do_get
      assigns(:user).pictures.should_not be_nil
    end

    it "show action should render show template" do
      do_get
      response.should render_template(:show)
    end
  end

end
