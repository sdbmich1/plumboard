require 'login_user_spec'

describe PostSearchesController do
  include LoginTestUser

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      allow(user).to receive(stubs) unless stubs.empty?
    end
  end

  def mock_post(stubs={})
    (@mock_post ||= mock_model(Post, stubs).as_null_object).tap do |post|
       allow(post).to receive(stubs) unless stubs.empty?
    end
  end

  def mock_listing(stubs={})
    (@mock_listing ||= mock_model(Listing, stubs).as_null_object).tap do |listing|
      allow(listing).to receive(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
  end

  describe 'GET /index' do
    before :each do
      @posts = double("posts")
      allow(Post).to receive(:search).and_return( @posts )
      allow(controller).to receive(:current_user).and_return(@user)
      allow(@user).to receive_message_chain(:user_pixi_points, :create).and_return(:success)
      allow(controller).to receive_message_chain(:query, :page, :add_points).and_return(:success)
    end

    def do_get
      xhr :get, :index, search: 'test'
    end

    it "should load the requested post" do
      allow(Post).to receive(:search).with('test').and_return(@posts)
      do_get
    end

    it "should assign @posts" do
      do_get
      expect(assigns(:posts)).to eq(@posts)
    end

    it "index action should render nothing" do
      do_get
      allow(controller).to receive(:render)
    end
  end
end
