require 'login_user_spec'

describe SettingsController do
  include LoginTestUser

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  def mock_category(stubs={})
    (@mock_category ||= mock_model(Category, stubs).as_null_object).tap do |category|
      user.stub(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
    @user = mock_user
  end

  describe 'GET index' do

    before :each do
      controller.stub!(:current_user).and_return(@user)
      do_get
    end

    def do_get
      get :index
    end

    it "should assign @user" do
      assigns(:user).should_not be_nil 
    end

    it "renders the :index view" do
      response.should render_template :index
    end
  end

  describe "xhr GET 'index'" do

    before :each do
      controller.stub!(:current_user).and_return(@user)
      do_get
    end

    def do_get
      xhr :get, :index
    end

    it "should assign @user" do
      assigns(:user).should_not be_nil 
    end

    it "should load nothing" do
      controller.stub!(:render)
    end
  end

  describe "GET 'password'" do

    before :each do
      controller.stub!(:current_user).and_return(@user)
      do_get
    end

    def do_get
      xhr :get, :password
    end

    it "should assign @user" do
      assigns(:user).should_not be_nil 
    end

    it "should load nothing" do
      controller.stub!(:render)
    end
  end

  describe "GET 'contact'" do

    before :each do
      controller.stub!(:current_user).and_return(@user)
      do_get
    end

    def do_get
      xhr :get, :contact, id: '1'
    end

    it "should assign @user" do
      assigns(:user).should_not be_nil 
    end

    it "should load nothing" do
      controller.stub!(:render)
    end
  end


  describe "GET 'delivery'" do

    before :each do
      controller.stub!(:current_user).and_return(@user)
      do_get
    end

    def do_get
      xhr :get, :delivery, id: '1'
    end

    it "should assign @user" do
      assigns(:user).should_not be_nil 
    end

    it "should load nothing" do
      controller.stub!(:render)
    end
  end
end
