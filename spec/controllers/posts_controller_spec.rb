require 'login_user_spec'

describe PostsController do
  include LoginTestUser

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  def mock_listing(stubs={})
    (@mock_listing ||= mock_model(Listing, stubs).as_null_object).tap do |listing|
      listing.stub(stubs) unless stubs.empty?
    end
  end

  def mock_post(stubs={})
    (@mock_post ||= mock_model(Post, stubs).as_null_object).tap do |post|
      post.stub(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
    @user = mock_user
    @listing = stub_model Listing
    @post = stub_model Post
    controller.stub!(:current_user).and_return(@user)
  end

  describe "POST create" do
    before :each do
      Post.stub!(:new).and_return(@post)
    end
    
    def do_create
      xhr :post, :create, :post => { pixi_id: '1', 'content'=>'test' }
    end

    context 'failure' do
      
      before :each do
        @post.stub!(:save).and_return(false)
      end

      it "should assign @post" do
        do_create
        assigns(:post).should_not be_nil 
      end

      it "should render nothing" do
        do_create
	controller.stub!(:render)
      end

      it "responds to JSON" do
        post :create, :post => { pixi_id: '1', 'content'=>'test' }, format: :json
	response.status.should_not eq(0)
      end
    end

    context 'success' do

      before :each do
        @post.stub!(:save).and_return(true)
        controller.stub!(:reload_data).and_return(true)
      end

      after (:each) do
        @comments = stub_model(Comment)
        Listing.stub!(:find_by_pixi_id).with('1').and_return(@listing)
        @listing.stub!(:comments).and_return( @comments )
      end
       
      it "should load the requested listing" do
        Listing.stub(:find_by_pixi_id).with('1').and_return(:success)
        do_create
      end

      it "should assign @post" do
        do_create
        assigns(:post).should_not be_nil 
      end
       
      it "should load the requested comments" do
        @listing.stub(:comments).and_return(@comments)
        do_create
      end

      it "should assign @comments" do
        do_create
        assigns(:comments).should == @comments
      end

      it "should load the requested post" do
        Post.stub(:new).with({'pixi_id'=>'1', 'content'=>'test' }) { mock_post(:save => true) }
        do_create
      end

      it "should assign @post" do
        do_create
        assigns(:post).should_not be_nil 
      end

      it "should change post count" do
        lambda do
          do_create
          should change(Post, :count).by(1)
        end
      end

      it "responds to JSON" do
        post :create, :post => { pixi_id: '1', 'content'=>'test' }, format: :json
	response.status.should_not eq(0)
      end
    end
  end

  describe 'GET sent' do

    before :each do
      @posts = stub_model(Post)
      Post.stub!(:get_sent_posts).and_return( @posts )
      @posts.stub!(:paginate).and_return( @posts )
    end

    def do_get
      xhr :get, :sent
    end

    it "should load the requested posts" do
      Post.stub!(:get_sent_posts).and_return( @posts )
      do_get
      assigns(:posts).should_not be_nil 
    end

    it "should render nothing" do
      do_get
      controller.stub!(:render)
    end

    it "responds to JSON" do
      get :sent, format: :json
      expect(response).to be_success
    end
  end

  describe "GET /mark" do
    before :each do
      @post = mock_model Post
      Post.stub!(:mark_as_read).with(@user).and_return(true)
    end
    
    def do_mark
      xhr :get, :mark
    end

    it "should render nothing" do
      do_mark
      controller.stub!(:render)
    end
  end

  describe "GET /show" do
    before :each do
      @posts = mock("posts")
      Post.stub!(:get_posts).and_return( @posts )
      @posts.stub!(:paginate).and_return( @posts )
    end
    
    def do_get
      xhr :get, :show, :id => 'reply', :page => '2'
    end

    it "should load the requested posts" do
      @user.stub(:incoming_posts).and_return(@posts)
      do_get
      assigns(:posts).should_not be_nil 
    end

    it "show action should render show template" do
      do_get
      response.should render_template(:show)
    end
  end

  describe 'xhr GET index' do

    before :each do
      @posts = stub_model(Post)
      Post.stub!(:get_posts).and_return( @posts )
      @posts.stub!(:paginate).and_return( @posts )
    end

    def do_get
      xhr :get, :index
    end

    it "should load the requested posts" do
      Post.stub!(:get_posts).and_return( @posts )
      do_get
      assigns(:posts).should_not be_nil 
    end

    it "index action should render index template" do
      do_get
      response.should render_template(:index)
    end

    it "responds to JSON" do
      get :index, format: :json
      expect(response).to be_success
    end
  end

  describe 'GET index' do

    before :each do
      @posts = stub_model(Post)
      Post.stub!(:get_posts).and_return( @posts )
      @posts.stub!(:paginate).and_return( @posts )
    end

    def do_get
      get :index
    end

    it "should load the requested posts" do
      Post.stub!(:get_posts).and_return( @posts )
      do_get
      assigns(:posts).should_not be_nil 
    end

    it "index action should render index template" do
      do_get
      response.should render_template(:index)
    end
  end

  describe "POST reply" do
    before :each do
      @post = mock_model Post
      controller.stub!(:mark_post).and_return(:success)
    end
    
    def do_reply
      xhr :post, :reply, id: '1', post: { pixi_id: '1', 'content'=>'test' }
    end

    context 'failure' do
      
      before :each do
        Post.stub!(:save).and_return(false)
        do_reply
      end

      it "should assign @post" do
        assigns(:post).should_not be_nil 
      end

      it "should render nothing" do
	controller.stub!(:render)
      end

      it "responds to JSON" do
        post :reply, :format=>:json
	response.status.should_not eq(200)
      end
    end

    context 'success' do

      before do
        Post.stub!(:save).and_return(true)
        @user.stub_chain(:reload, :incoming_posts).and_return( @posts )
        @posts.stub!(:paginate).and_return( @posts )
      end
       
      it "should load the requested post" do
        Post.stub(:new).with({'pixi_id'=>'1', 'content'=>'test' }) { mock_post(:save => true) }
        do_reply
      end

      it "should assign @post" do
        do_reply
        assigns(:post).should_not be_nil 
      end

      it "should load the requested posts" do
        Post.stub(:get_unread).with(@user).and_return(@posts)
        do_reply
        assigns(:posts).should == @posts
      end

      it "should change post count" do
        lambda do
          do_reply
          should change(Post, :count).by(1)
        end
      end

      it "responds to JSON" do
        post :reply, id: '1', post: { pixi_id: '1', 'content'=>'test' }, format: :json
	response.status.should_not eq(0)
      end
    end
  end
end
