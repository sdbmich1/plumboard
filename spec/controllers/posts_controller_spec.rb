require 'login_user_spec'

describe PostsController do
  include LoginTestUser

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      allow(user).to receive(stubs) unless stubs.empty?
    end
  end

  def mock_listing(stubs={})
    (@mock_listing ||= mock_model(Listing, stubs).as_null_object).tap do |listing|
      allow(listing).to receive(stubs) unless stubs.empty?
    end
  end

  def mock_conversation(stubs={})
    (@mock_conversation ||= mock_model(Conversation, stubs).as_null_object).tap do |conversation|
      allow(conversation).to receive(stubs) unless stubs.empty?
    end
  end

  def mock_post(stubs={})
    (@mock_post ||= mock_model(Post, stubs).as_null_object).tap do |post|
      allow(post).to receive(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
    @user = mock_user
    @listing = stub_model Listing
    @post = stub_model Post
    allow(controller).to receive(:current_user).and_return(@user)
  end

  describe "GET /mark" do
    before :each do
      @post = mock_model Post
      allow(Post).to receive(:mark_as_read).with(@user).and_return(true)
    end
    
    def do_mark
      xhr :get, :mark
    end

    it "should render nothing" do
      do_mark
      allow(controller).to receive(:render)
    end
  end

  describe "PUT /mark_read" do
    before :each do
      @post = mock_model Post
      allow(Post).to receive(:find).and_return( @post )
      @post.stub_chain(:mark_as_read!, :for, :unread?).with(@user).and_return(true)
      allow(@post).to receive(:unread?).and_return(true)
    end
    
    def do_mark
      xhr :put, :mark_read, id: '1'
    end

    it "should render nothing" do
      do_mark
      allow(controller).to receive(:render)
    end
  end

  describe 'PUT` remove post' do
     before (:each) do
      @user = mock_model(User, :id => 3)
      @post = mock_model(Post, :id => 1, :pixi_id => 1, :user_id => 3, conversation_id: 1)
      allow(Post).to receive(:find).and_return( @post )
    end

    def do_remove
      xhr :put, :remove, id: '1'
    end

    context "with valid params" do
      before (:each) do
        allow(@post).to receive(:remove_post).and_return(true)
        allow(controller).to receive(:set_redirect_path).and_return('/conversations')
      end

      it "should load the requested post" do
        allow(Post).to receive(:find) { @post }
        do_remove
      end

      it "should update the requested post" do
        allow(Post).to receive(:find).with("1") { @post }
        expect(@post).to receive(:remove_post)
        do_remove
      end

      it "should assign @post" do
        allow(Post).to receive(:find) { mock_post }
        do_remove
        expect(assigns(:post)).not_to be_nil 
      end
    end

    context "with invalid params" do
    
      before (:each) do
        allow(@post).to receive(:remove_post).and_return(false)
      end

      it "should load the requested post" do
        allow(Post).to receive(:find) { @post }
        do_remove
      end

      it "should assign @post" do
        allow(Post).to receive(:find) { mock_post(:update_attributes => false) }
        do_remove
        expect(assigns(:post)).not_to be_nil 
      end

      it "renders nothing" do 
        allow(Post).to receive(:find) { mock_post(:update_attributes => false) }
        do_remove
        allow(controller).to receive(:render)
      end
    end
  end
end
