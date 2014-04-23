require 'login_user_spec'

describe PostSearchesController do
  include LoginTestUser

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  def mock_post(stubs={})
    (@mock_post ||= mock_model(Post, stubs).as_null_object).tap do |post|
       post.stub(stubs) unless stubs.empty?
    end
  end

  def mock_listing(stubs={})
    (@mock_listing ||= mock_model(Listing, stubs).as_null_object).tap do |listing|
      listing.stub(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
  end

  describe 'GET /index' do
    before :each do
      @posts = mock("posts")
      Post.stub!(:search).and_return( @posts )
      controller.stub!(:current_user).and_return(@user)
      @user.stub_chain(:user_pixi_points, :create).and_return(:success)
      controller.stub_chain(:query, :page, :add_points).and_return(:success)
    end

    def do_get
      xhr :get, :index, search: 'test'
    end

    it "should load the requested post" do
      Post.stub(:search).with('test').and_return(@posts)
      do_get
    end

    it "should assign @posts" do
      do_get
      assigns(:posts).should == @posts
    end

    it "index action should render nothing" do
      do_get
      controller.stub!(:render)
    end
  end
end
