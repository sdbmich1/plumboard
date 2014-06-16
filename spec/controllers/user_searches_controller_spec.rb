require 'login_user_spec'

describe UserSearchesController do
  include LoginTestUser

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
       user.stub(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
  end

  describe 'GET /index' do
    before :each do
      @users = mock("users")
      User.stub!(:search).and_return( @users )
      controller.stub!(:current_user).and_return(@user)
      controller.stub_chain(:query, :page).and_return(:success)
    end

    def do_get
      xhr :get, :index, search_user: 'test'
    end

    it "should load the requested user" do
      User.stub(:search).with('test').and_return(@users)
      do_get
    end

    it "should assign @users" do
      do_get
      assigns(:users).should == @users
    end

    it "index action should render nothing" do
      do_get
      controller.stub!(:render)
    end
  end

end
