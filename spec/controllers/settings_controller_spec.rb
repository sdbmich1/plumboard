require 'login_user_spec'

describe SettingsController do
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

    before :each do
      do_get
      controller.stub!(:current_user).and_return(@user)
    end

    def do_get
      get :index
    end

    it "should load the requested user" do
      controller.current_user.should == @user
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
      do_get
      controller.stub!(:current_user).and_return(@user)
    end

    def do_get
      xhr :get, :index
    end

    it "should load the requested user" do
      controller.current_user.should == @user
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
      do_get
      controller.stub!(:current_user).and_return(@user)
    end

    def do_get
      xhr :get, :password
    end

    it "should load the requested user" do
      controller.current_user.should == @user
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
      do_get
      @contacts = stub_model(Contact)
      controller.stub!(:current_user).and_return(@user)
      @user.stub!(:contacts).and_return( @contacts )
    end

    def do_get
      xhr :get, :contact, id: '1'
    end

    it "should load the requested user" do
      controller.current_user.should == @user
    end

    it "should assign @user" do
      assigns(:user).should_not be_nil 
    end

    it "should assign @contacts" do
      do_get
      assigns(:user).contacts.should_not be_nil
    end

    it "should load nothing" do
      controller.stub!(:render)
    end
  end
end
