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
    controller.stub!(:current_user).and_return(@user)
  end

  describe 'GET index' do
    before(:each) do
      @users = mock("users")
      User.stub!(:get_by_type).and_return(@users)
      @users.stub!(:paginate).and_return(@users)
    end

    def do_get
      get :index
    end

    it "renders the :index view" do
      do_get
      response.should render_template :index
    end

    it "should assign @users" do
      User.should_receive(:get_by_type).and_return(@users)
      do_get 
      assigns(:users).should_not be_nil
    end

    it "responds to CSV" do
      get :index, :format => 'csv'
      expect(response).to be_success
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

  describe "GET 'edit/:id'" do

    before :each do
      User.stub!(:find).and_return( @user )
    end

    def do_get
      get :edit, id: '1'
    end

    it "should load the requested user" do
      User.stub(:find).with('1').and_return(@user)
      do_get
    end

    it "should assign @user" do
      do_get
      assigns(:user).should_not be_nil
    end

    it "should load the edit template" do
      do_get
      response.should render_template :edit
    end
  end

  describe "PUT /:id" do
    before (:each) do
      controller.stub_chain(:changing_email, :is_profile?).and_return(true)
      controller.stub!(:match).and_return(true)
      User.stub!(:find).and_return( @user )
    end

    def do_update
      xhr :put, :update, :id => "1", :user => {'first_name'=>'test', 'last_name' => 'test'}, target: 'shared/user_form'
    end

    context "with valid params" do
      before (:each) do
        @user.stub(:update_attributes).and_return(true)
      end

      it "should load the requested user" do
        User.stub(:find) { @user }
        do_update
      end

      it "should update the requested user" do
        User.stub(:find).with("1") { mock_user }
	mock_user.should_receive(:update_attributes).with({'first_name'=>'test', 'last_name' => 'test'})
        do_update
      end

      it "should assign @user" do
        User.stub(:find) { mock_user(:update_attributes => true) }
        do_update
        assigns(:user).should_not be_nil 
      end
      
      it "should render nothing" do
        do_update
        controller.stub!(:render)
      end
    end

    context "with invalid params" do
      before (:each) do
        @user.stub(:update_attributes).and_return(false)
      end

      it "should load the requested user" do
        User.stub(:find) { @user }
        do_update
      end

      it "should assign @user" do
        User.stub(:find) { mock_user(:update_attributes => false) }
        do_update
        assigns(:user).should_not be_nil 
      end

      it "renders nothing" do 
        controller.stub!(:render)
      end
    end
  end

  describe 'GET /buyer_name' do
    before :each do
      @users = stub_model(User)
      User.stub!(:search).and_return( @users )
      controller.stub_chain(:query).and_return(:success)
    end

    def do_get
      xhr :get, :buyer_name, search: 'test'
    end

    it "should load the requested user" do
      User.stub(:search).with('test').and_return(@users)
      do_get
    end

    it "assigns @users" do
      do_get
      assigns(:users).should == @users
    end

    it "renders nothing" do
      do_get
      controller.stub!(:render)
    end

    it "responds to JSON" do
      get :buyer_name, search: 'test', format: :json
      expect(response).to be_success
    end
  end

  describe 'GET states' do
    before(:each) do
      @states = stub_model(State)
      State.stub!(:all).and_return(@states)
    end

    def do_get
      xhr :get, :states
    end

    it "loads the requested data" do
      State.stub(:all).and_return(@users)
      do_get
    end

    it "renders nothing" do
      do_get
      controller.stub!(:render)
    end

    it "assigns @states" do
      do_get 
      assigns(:states).should_not be_nil
    end

    it "responds to JSON" do
      get :states, format: :json
      expect(response).to be_success
    end
  end

end
