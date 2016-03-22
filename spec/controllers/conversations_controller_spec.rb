require 'login_user_spec'

describe ConversationsController do
  include LoginTestUser

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      allow(user).to receive_messages(stubs) unless stubs.empty?
    end
  end

  def mock_listing(stubs={})
    (@mock_listing ||= mock_model(Listing, stubs).as_null_object).tap do |listing|
      allow(listing).to receive_messages(stubs) unless stubs.empty?
    end
  end

  def mock_conversation(stubs={})
    (@mock_conversation ||= mock_model(Conversation, stubs).as_null_object).tap do |conversation|
      allow(conversation).to receive_messages(stubs) unless stubs.empty?
    end
  end

  def mock_post(stubs={})
    (@mock_post ||= mock_model(Post, stubs).as_null_object).tap do |post|
      allow(post).to receive_messages(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
    @user = mock_user
    @listing = stub_model Listing
    @conversation = stub_model Conversation
    allow(controller).to receive(:current_user).and_return(@user)
  end

  describe "CONVERSATION create" do
    before :each do
      allow(Conversation).to receive(:new).and_return(@conversation)
    end
    
    def do_create
      xhr :post, :create, :conversation => {pixi_id: '1', user_id: '1', recipient_id: '2', :post => {pixi_id: '1', user_id: '1', 'content'=>'test'}}
    end

    context 'failure' do
      
      before :each do
        allow(@conversation).to receive(:save).and_return(false)
      end

      it "should assign @conversation" do
        do_create
        expect(assigns(:conversation)).not_to be_nil 
      end

      it "should render nothing" do
        do_create
        allow(controller).to receive(:render)
      end

      it "responds to JSON" do
        expect(response.status).not_to eq(0)
      end
    end

    context 'success' do

      before :each do
        allow(@conversation).to receive(:save).and_return(true)
        allow(controller).to receive(:reload_data).and_return(true)
      end

      it "should assign @conversation" do
        do_create
        expect(assigns(:conversation)).not_to be_nil 
      end

      it "should load the requested conversation" do
        allow(Conversation).to receive(:new).with({'id' => 1, 'pixi_id'=>'1'}) { mock_post(:save => true) }
        do_create
      end

      it "should change conversation count" do
        lambda do
          do_create
          is_expected.to change(Conversation, :count).by(1)
        end
      end

      it "should change post count" do
        lambda do
          do_create
          is_expected.to change(Post, :count).by(1)
        end
      end

      it "responds to JSON" do
        do_create
        expect(response.status).not_to eq(0)
      end
    end
  end

  describe 'xhr GET index' do

    before :each do
      @conversations = stub_model(Conversation)
      allow(Conversation).to receive(:get_specific_conversations).and_return( @conversations )
      allow(@conversations).to receive(:paginate).and_return( @conversations )
    end

    def do_get
      xhr :get, :index
    end

    it "should load the requested conversations" do
      allow(Conversation).to receive(:get_specific_conversations).and_return( @conversations )
      do_get
      expect(assigns(:conversations)).not_to be_nil 
    end

    it "should render nothing" do
      do_get
      allow(controller).to receive(:render)
    end

    it "responds to JSON" do
      get :index, format: :json
      expect(response).to be_success
    end
  end

  describe 'GET index' do

    before :each do
      @conversations = stub_model(Conversation)
      allow(Conversation).to receive(:get_specific_conversations).and_return( @conversations )
      allow(@conversations).to receive(:paginate).and_return( @conversations )
    end

    def do_get
      get :index
    end

    it "should load the requested conversations" do
      allow(Conversation).to receive(:get_specific_conversations).and_return( @conversations )
      do_get
      expect(assigns(:conversations)).not_to be_nil 
    end

    it "index action should render index template" do
      do_get
      expect(response).to render_template(:index)
    end

    it "responds to JSON" do
      get :index, format: :json
      expect(response).to be_success
    end
  end

  describe "POST conversation reply" do
    before :each do
      @conversation = stub_model(Conversation, :id => 1, :pixi_id => 1)
      allow(Conversation).to receive(:find).and_return(@conversation)
      allow(controller).to receive(:mark_post).and_return(true)
    end
    
    def do_reply
      xhr :post, :reply, id: '1', status: 'received', post: { pixi_id: '1', 'content'=>'test' }
    end

    context 'failure' do
      
      before :each do
        allow(@conversation).to receive(:save).and_return(false)
        do_reply
      end

      it "should assign @conversation" do
        expect(assigns(:conversation)).not_to be_nil 
      end

      it "should render nothing" do
        allow(controller).to receive(:render)
      end

      it "responds to JSON" do
        xhr :post, :reply, id: '1', post: { pixi_id: '1', 'content'=>'test' }, format: :json
        expect(response.status).not_to eq(0)
      end
    end

    context 'success' do

      before do
        allow(@conversation).to receive(:save).and_return(true)
        allow(@conversation).to receive(:reload).and_return(@conversation)
      end

      it "should assign @conversation" do
        do_reply
        expect(assigns(:conversation)).not_to be_nil 
      end

      it "should load the requested conversation" do
        allow(Conversation).to receive(:find_by_pixi_id) { @conversation }
        do_reply
      end

      it "should change post count" do
        lambda do
          do_reply
          is_expected.to change(Post, :count).by(1)
        end
      end

      it "should not change conversation count" do
        lambda do
          do_reply
          is_expected.to change(Conversation, :count).by(0)
        end
      end

      it "responds to JSON" do
        post :reply,  id: '1', post: { pixi_id: '1', 'content'=>'test' }, format: :json
        _expected = {:conversation => @conversation}.to_json
        expect(response.body).to eq(_expected)
      end
    end
  end

  describe 'GET show conversation' do
     before (:each) do
      allow(Conversation).to receive_message_chain(:inc_show_list, :find).and_return( @conversation )
      allow(@conversation).to receive(:mark_all_posts).and_return(:success)
      @user = mock_model(User, :id => 3)
      @conversation = mock_model(Conversation, :id => 1, :pixi_id => 1, :user_id => 3)
      allow(controller).to receive(:load_data).and_return(:success)
    end

    def do_show val='1'
      xhr :get, :show, id: val
    end

    context "with valid params" do

      it "should load the requested conversation" do
        allow(Conversation).to receive(:find) { mock_conversation }
        do_show
      end

      it "should find the correct conversation" do
        allow(Conversation).to receive(:find) { mock_conversation }
        expect(Conversation).to receive(:find)
        do_show
      end

      it "should assign @conversation" do
        allow(Conversation).to receive(:find) { mock_conversation }
        do_show
        expect(assigns(:conversation)).not_to be_nil 
      end
    end
  end

  describe "PUT /:id" do
    before (:each) do
      allow(Conversation).to receive(:find).and_return( @conversation )
      @conv = {'pixi_id'=> '1', 'user_id'=> '1', 'recipient_id'=> '2', 'status' => 'active', 'recipient_status'=>'active'} 
    end

    def do_update
      xhr :put, :update, :id => "1", :conversation => {'pixi_id'=> '1', 'user_id'=> '1', 'recipient_id'=> '2', 'status' => 'active', 'recipient_status'=>'active'} 
    end

    context "with valid params" do
      before (:each) do
        allow(@conversation).to receive(:update_attributes).and_return(true)
        allow(controller).to receive(:reload_data).and_return(true)
      end

      it "should load the requested conversation" do
        allow(Conversation).to receive(:find) { @conversation }
        do_update
      end

      it "should update the requested conversation" do
        allow(Conversation).to receive(:find).with("1") { mock_conversation }
	expect(mock_conversation).to receive(:update_attributes).with(@conv)
        do_update
      end

      it "should assign @conversation" do
        allow(Conversation).to receive(:find) { mock_conversation(:update_attributes => true) }
        do_update
        expect(assigns(:conversation)).not_to be_nil 
      end

      it "redirects to the updated conversation" do
        do_update
        allow(controller).to receive(:render)
      end

      it "responds to JSON" do
        do_update
        expect(response.status).not_to eq(0)
      end
    end
  end

  describe 'PUT remove conversation' do
    before (:each) do
      allow(Conversation).to receive(:find).and_return( @conversation )
      @user = mock_model(User, :id => 3)
      @conversation = mock_model(Conversation, :id => 1, :pixi_id => 1, :user_id => 3)
    end

    def do_remove
      xhr :put, :remove, id: '1'
    end

    context "with valid params" do
      before (:each) do
        allow(Conversation).to receive(:remove_conv).and_return(true)
      end

      it "should load the requested conversation" do
        allow(Conversation).to receive(:find) { @conversation }
        do_remove
      end

      it "should update the requested conversation" do
        allow(Conversation).to receive(:find).with("1") { @conversation }
        expect(Conversation).to receive(:remove_conv)
        do_remove
      end

      it "should assign @conversation" do
        allow(Conversation).to receive(:find) { mock_conversation }
        do_remove
        expect(assigns(:conversation)).not_to be_nil 
      end

      it "redirects to the updated conversation" do
        do_remove
        expect(response).to be_redirect
      end
    end

    context "with invalid params" do
    
      before (:each) do
        allow(Conversation).to receive(:remove_conv).and_return(false)
      end

      it "should load the requested conversation" do
        allow(Conversation).to receive(:find) { @conversation }
        do_remove
      end

      it "should assign @conversation" do
        allow(Conversation).to receive(:find) { mock_conversation(:update_attributes => false) }
        do_remove
        expect(assigns(:conversation)).not_to be_nil 
      end

      it "renders nothing" do 
        allow(Conversation).to receive(:find) { mock_conversation(:update_attributes => false) }
        do_remove
        expect(response.body).to eq("")
      end
    end
  end
end
  

