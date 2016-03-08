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
    allow(controller).to receive(:current_user).and_return(@user)
  end

  describe 'GET index' do
    before(:each) do
      @user = stub_model(User)
      @user.birth_date = DateTime.current
      allow(User).to receive(:get_by_type).and_return(@user)
      allow(@user).to receive(:paginate).and_return(@user)
      controller.stub_chain(:load_data, :check_permissions).and_return(:success)
    end

    def do_get
      get :index
    end

    it "renders the :index view" do
      do_get
      expect(response).to render_template :index
    end

    it "should assign @user" do
      expect(User).to receive(:get_by_type).and_return(@user)
      do_get 
      expect(assigns(:users)).not_to be_nil
    end

    it "responds to CSV" do
      get :index, :format => 'csv'
      expect(response).to be_success
    end
  end

  describe 'GET show/:id' do
    before :each do
      @photo = stub_model(Picture)
      allow(User).to receive(:find).and_return( @user )
      allow(@user).to receive(:pictures).and_return( @photo )
    end

    def do_get
      get :show, :id => @user
    end

    it "should show the requested user" do
      do_get
      expect(response).to be_success
    end

    it "should load the requested user" do
      allow(User).to receive(:find).with(@user.id).and_return(@user)
      do_get
    end

    it "should assign @user" do
      do_get
      expect(assigns(:user)).not_to be_nil
    end

    it "should assign @photo" do
      do_get
      expect(assigns(:user).pictures).not_to be_nil
    end

    it "show action should render show template" do
      do_get
      expect(response).to render_template(:show)
    end
  end

  describe "GET 'edit/:id'" do

    before :each do
      allow(User).to receive(:find).and_return( @user )
    end

    def do_get
      get :edit, id: '1'
    end

    it "should load the requested user" do
      allow(User).to receive(:find).with('1').and_return(@user)
      do_get
    end

    it "should assign @user" do
      do_get
      expect(assigns(:user)).not_to be_nil
    end

    it "should load the edit template" do
      do_get
      expect(response).to render_template :edit
    end
  end

  describe "PUT /:id" do
    before (:each) do
      controller.stub_chain(:changing_email, :is_profile?).and_return(true)
      allow(controller).to receive(:match).and_return(true)
      allow(User).to receive(:find).and_return( @user )
    end

    def do_update
      xhr :put, :update, :id => "1", :user => {'first_name'=>'test', 'last_name' => 'test'}, target: 'shared/user_form'
    end

    context "with valid params" do
      before (:each) do
        allow(@user).to receive(:update_attributes).and_return(true)
      end

      it "should load the requested user" do
        allow(User).to receive(:find) { @user }
        do_update
      end

      it "should update the requested user" do
        allow(User).to receive(:find).with("1") { mock_user }
	expect(mock_user).to receive(:update_attributes).with({'first_name'=>'test', 'last_name' => 'test'})
        do_update
      end

      it "should assign @user" do
        allow(User).to receive(:find) { mock_user(:update_attributes => true) }
        do_update
        expect(assigns(:user)).not_to be_nil 
      end
      
      it "should render nothing" do
        do_update
        allow(controller).to receive(:render)
      end
    end

    context "with invalid params" do
      before (:each) do
        allow(@user).to receive(:update_attributes).and_return(false)
      end

      it "should load the requested user" do
        allow(User).to receive(:find) { @user }
        do_update
      end

      it "should assign @user" do
        allow(User).to receive(:find) { mock_user(:update_attributes => false) }
        do_update
        expect(assigns(:user)).not_to be_nil 
      end

      it "renders nothing" do 
        allow(controller).to receive(:render)
      end
    end
  end

  describe 'GET /buyer_name' do
    before :each do
      @users = stub_model(User)
      allow(User).to receive(:search).and_return( @users )
      controller.stub_chain(:query).and_return(:success)
    end

    def do_get
      xhr :get, :buyer_name, search: 'test'
    end

    it "should load the requested user" do
      allow(User).to receive(:search).with('test').and_return(@users)
      do_get
    end

    it "assigns @users" do
      do_get
      expect(assigns(:users)).to eq(@users)
    end

    it "renders nothing" do
      do_get
      allow(controller).to receive(:render)
    end

    it "responds to JSON" do
      get :buyer_name, search: 'test', format: :json
      expect(response).to be_success
    end
  end

  describe 'GET states' do
    before(:each) do
      @states = stub_model(State)
      allow(State).to receive(:all).and_return(@states)
    end

    def do_get
      xhr :get, :states
    end

    it "loads the requested data" do
      allow(State).to receive(:all).and_return(@users)
      do_get
    end

    it "renders nothing" do
      do_get
      allow(controller).to receive(:render)
    end

    it "assigns @states" do
      do_get 
      expect(assigns(:states)).not_to be_nil
    end

    it "responds to JSON" do
      get :states, format: :json
      expect(response).to be_success
    end
  end
end
