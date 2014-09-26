require 'login_user_spec'

describe ConversationsController do
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
    @conversation = stub_model Conversation
    controller.stub!(:current_user).and_return(@user)
  end

  describe "CONVERSATION create" do
    before :each do
      Conversation.stub!(:new).and_return(@conversation)
      Post.stub!(:new).and_return(@post)
    end
    
    def do_create
      post :create
    end

    context 'failure' do
      
      before :each do
        @post.stub!(:save).and_return(false)
        @conversation.stub!(:save).and_return(false)
      end

      it "should assign @post" do
        do_create
        assigns(:post).should_not be_nil 
      end

      it "should assign @conversation" do
        do_create
        assigns(:conversation).should_not be_nil 
        assigns(:post).should_not be_nil 
      end

      it "should render nothing" do
        do_create
        controller.stub!(:render)
      end

      it "responds to JSON" do
        response.status.should_not eq(0)
      end
    end

    context 'success' do

      before :each do
        @post.stub!(:save).and_return(true)
        @conversation.stub!(:save).and_return(true)
      end
       
      it "should assign @post" do
        do_create
        assigns(:post).should_not be_nil 
      end

      it "should assign @conversation" do
        do_create
        assigns(:conversation).should_not be_nil 
      end

      it "should load the requested conversation" do
        Post.stub(:new).with({'pixi_id'=>'1', 'content'=>'test' }) { mock_post(:save => true) }
        Conversation.stub(:new).with({'id' => 1, 'pixi_id'=>'1'}) { mock_post(:save => true) }
        do_create
      end

      it "should assign @post" do
        do_create
        assigns(:post).should_not be_nil 
      end

      it "should assign @post" do
        do_create
        assigns(:conversation).should_not be_nil 
      end

      it "should change conversation count" do
        lambda do
          do_create
          should change(Conversation, :count).by(1)
        end
      end

      it "should change post count" do
        lambda do
          do_create
          should change(Post, :count).by(1)
        end
      end

      it "responds to JSON" do
        do_create
        response.status.should_not eq(0)
      end
    end
  end

  describe 'GET sent' do

    before :each do
      @conversations = stub_model(Conversation)
      Conversation.stub!(:get_specific_conversations).and_return( @conversations )
      @conversations.stub!(:paginate).and_return( @conversations )
    end

    def do_get
      xhr :get, :sent
    end

    it "should load the requested conversations" do
      Conversation.stub!(:get_specific_conversations).and_return( @conversations )
      do_get
      assigns(:conversations).should_not be_nil 
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

  describe 'GET index' do

    before :each do
      @conversations = stub_model(Conversation)
      Conversation.stub!(:get_specific_conversations).and_return( @conversations )
      @conversations.stub!(:paginate).and_return( @conversations )
    end

    def do_get
      get :index
    end

    it "should load the requested conversations" do
      Conversation.stub!(:get_specific_conversations).and_return( @conversations )
      do_get
      assigns(:conversations).should_not be_nil 
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

  describe "POST conversation reply" do
    before :each do
      @post = stub_model(Post, :id => 2, :pixi_id => 1)
      @conversation = stub_model(Conversation, :id => 1, :pixi_id => 1)
      Conversation.stub!(:find).and_return(@conversation)
      controller.stub_chain(:mark_post, :mark_as_read).and_return(true)
      @conversation.stub_chain(:posts, :build).and_return(@post)
    end
    
    def do_reply
      xhr :post, :reply, id: '1', post: { pixi_id: '1', 'content'=>'test' }
    end

    context 'failure' do
      
      before :each do
        @conversation.stub!(:save).and_return(false)
        do_reply
      end

      it "should assign @post" do
        assigns(:post).should_not be_nil 
      end

      it "should assign @conversation" do
        assigns(:conversation).should_not be_nil 
      end

      it "should render nothing" do
        controller.stub!(:render)
      end

      it "responds to JSON" do
        xhr :post, :reply, id: '1', post: { pixi_id: '1', 'content'=>'test' }, format: :json
        response.status.should_not eq(200)
      end
    end

    context 'success' do

      before do
        @conversation.stub!(:save).and_return(true)
        Conversation.stub(:get_specific_conversations).and_return(@conversations)
        @conversations.stub!(:paginate).and_return( @conversations )
      end
       
      it "should assign @post" do
        do_reply
        assigns(:post).should_not be_nil 
      end

      it "should assign @conversation" do
        do_reply
        assigns(:conversation).should_not be_nil 
      end

      it "should load the requested conversations" do
        Conversation.stub(:get_specific_conversations).and_return(@conversations)
        do_reply
        assigns(:conversations).should == @conversations
      end

      it "should change post count" do
        lambda do
          do_reply
          should change(Post, :count).by(1)
        end
      end

      it "should not change conversation count" do
        lambda do
          do_reply
          should change(Conversation, :count).by(0)
        end
      end

      it "responds to JSON" do
        post :reply,  id: '1', post: { pixi_id: '1', 'content'=>'test' }, format: :json
        _expected = {:conversation => @conversation}.to_json
        response.body.should == _expected
      end
    end
  end

  describe 'GET show conversation' do
     before (:each) do
      @posts = mock_model(Post)
      Conversation.stub_chain(:inc_show_list, :find).and_return( @conversation )
      @conversation.stub!(:posts).and_return(@posts)
      @user = mock_model(User, :id => 3)
      @post = mock_model(Post, :id => 2, :pixi_id => 1, :user_id => 3)
      @conversation.stub_chain(:posts, :build).and_return(@post)
      @conversation = mock_model(Conversation, :id => 1, :pixi_id => 1, :user_id => 3)
      controller.stub_chain(:load_data, :mark_post).and_return(:success)
    end

    def do_show val='1'
      xhr :get, :show, id: val
    end

    context "with valid params" do

      it "should load the requested conversation" do
        Conversation.stub(:find) { mock_conversation }
        @conversation.stub_chain(:posts, :build).and_return( mock_post )
        @conversation.stub(:posts).and_return( mock_post )
        do_show
      end

      it "should find the correct conversation" do
        Conversation.stub(:find) { mock_conversation }
        @conversation.stub_chain(:posts, :build).and_return( mock_post )
        @conversation.stub(:posts).and_return( mock_post )
        Conversation.should_receive(:find)
        do_show
      end

      it "should assign @conversation" do
        Conversation.stub!(:find) { mock_conversation }
        @conversation.stub_chain(:posts, :build).and_return( mock_post )
        @conversation.stub(:posts).and_return( mock_post )
        do_show
        assigns(:conversation).should_not be_nil 
      end

      it "should assign @posts" do
        Conversation.stub(:find) { mock_conversation }
        @conversation.stub_chain(:posts, :build).and_return( mock_post )
        @conversation.stub(:posts).and_return( mock_post )
        do_show
        assigns(:posts).should_not be_nil 
      end

      it "should assign @post" do
        Conversation.stub(:find) { mock_conversation }
        @conversation.stub_chain(:posts, :build).and_return( mock_post )
        @conversation.stub(:posts).and_return( mock_post )
        do_show
        assigns(:post).should_not be_nil 
      end
    end
  end

  describe 'PUT remove conversation' do
    before (:each) do
      Conversation.stub!(:find).and_return( @conversation )
      @user = mock_model(User, :id => 3)
      @post = mock_model(Post, :id => 2, :pixi_id => 1, :user_id => 3)
      @conversation = mock_model(Conversation, :id => 1, :pixi_id => 1, :user_id => 3)
    end

    def do_remove
      xhr :put, :remove, id: '1'
    end

    context "with valid params" do
      before (:each) do
        Conversation.stub!(:remove_conv).and_return(true)
      end

      it "should load the requested conversation" do
        Conversation.stub(:find) { @conversation }
        do_remove
      end

      it "should update the requested conversation" do
        Conversation.stub(:find).with("1") { @conversation }
        Conversation.should_receive(:remove_conv)
        do_remove
      end

      it "should assign @conversation" do
        Conversation.stub(:find) { mock_conversation }
        do_remove
        assigns(:conversation).should_not be_nil 
      end

      it "redirects to the updated conversation" do
        do_remove
        response.should be_redirect
      end
    end

    context "with invalid params" do
    
      before (:each) do
        Conversation.stub!(:remove_conv).and_return(false)
      end

      it "should load the requested conversation" do
        Conversation.stub(:find) { @conversation }
        do_remove
      end

      it "should assign @conversation" do
        Conversation.stub(:find) { mock_conversation(:update_attributes => false) }
        do_remove
        assigns(:conversation).should_not be_nil 
      end

      it "renders nothing" do 
        Conversation.stub(:find) { mock_conversation(:update_attributes => false) }
        do_remove
        response.body.should == " "
      end
    end
  end
end
  

