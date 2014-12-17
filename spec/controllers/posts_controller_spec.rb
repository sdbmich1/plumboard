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

  def mock_conversation(stubs={})
    (@mock_conversation ||= mock_model(Conversation, stubs).as_null_object).tap do |conversation|
      conversation.stub(stubs) unless stubs.empty?
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
      @conversation = stub_model Conversation
      Conversation.stub!(:get_conv).and_return(@conversation)
      @conversation.stub_chain(:posts, :build).and_return(@post)
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

  describe "PUT /mark_read" do
    before :each do
      @post = mock_model Post
      Post.stub!(:find).and_return( @post )
      @post.stub_chain(:mark_as_read!, :for, :unread?).with(@user).and_return(true)
      @post.stub!(:unread?).and_return(true)
    end
    
    def do_mark
      xhr :put, :mark_read, id: '1'
    end

    it "should render nothing" do
      do_mark
      controller.stub!(:render)
    end
  end

  describe 'GET remove post' do
     before (:each) do
      @user = mock_model(User, :id => 3)
      @post = mock_model(Post, :id => 1, :pixi_id => 1, :user_id => 3, conversation_id: 1)
      Post.stub!(:find).and_return( @post )
    end

    def do_remove
      xhr :get, :remove, id: '1'
    end

    context "with valid params" do
      before (:each) do
        @post.stub!(:remove_post).and_return(true)
        controller.stub!(:set_redirect_path).and_return('/conversations')
      end

      it "should load the requested post" do
        Post.stub(:find) { @post }
        do_remove
      end

      it "should update the requested post" do
        Post.stub(:find).with("1") { @post }
        @post.should_receive(:remove_post)
        do_remove
      end

      it "should assign @post" do
        Post.stub(:find) { mock_post }
        do_remove
        assigns(:post).should_not be_nil 
      end

      it "redirects to the updated message or conversations" do
        do_remove
        response.should be_redirect
      end
    end

    context "with invalid params" do
    
      before (:each) do
        @post.stub!(:remove_post).and_return(false)
      end

      it "should load the requested post" do
        Post.stub(:find) { @post }
        do_remove
      end

      it "should assign @post" do
        Post.stub(:find) { mock_post(:update_attributes => false) }
        do_remove
        assigns(:post).should_not be_nil 
      end

      it "renders nothing" do 
        Post.stub(:find) { mock_post(:update_attributes => false) }
        do_remove
        controller.stub!(:render)
      end
    end
  end
end
