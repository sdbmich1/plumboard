require 'login_user_spec'

describe PixiPostsController do
  include LoginTestUser

  def mock_post(stubs={})
    (@mock_post ||= mock_model(PixiPost, stubs).as_null_object).tap do |post|
      post.stub(stubs) unless stubs.empty?
    end
  end

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
    @post = stub_model(PixiPost, :id=>1, user_id: 1, quantity: 1, value: 60, description: "Guitar for Sale")
    controller.stub!(:current_user).and_return(@user)
  end

  def set_admin
    @abilities = Ability.new(@user)
    Ability.stub(:new).and_return(@abilities)
    @abilities.stub!(:can?).and_return(true)
  end

  describe 'GET show/:id' do
    before :each do
      PixiPost.stub!(:find).and_return( @post )
    end

    def do_get
      get :show, :id => '1'
    end

    it "should show the requested post" do
      do_get
      response.should be_success
    end

    it "should load the requested post" do
      PixiPost.stub(:find).with('1').and_return(@post)
      do_get
    end

    it "should assign @post" do
      do_get
      assigns(:post).should_not be_nil
    end

    it "show action should render show template" do
      do_get
      response.should render_template(:show)
    end

    it "responds to JSON" do
      @expected = { :post  => @post }.to_json
      get  :show, :id => '1', format: :json
      response.body.should_not be_nil
    end
  end

  describe "GET 'new'" do

    before :each do
      PixiPost.stub!(:load_new).and_return( @post )
      controller.stub!(:set_zip).and_return(:success)
    end

    def do_get
      get :new, zip: '90201'
    end

    it "should assign @post" do
      do_get
      assigns(:post).should_not be_nil
    end

    it "new action should render new template" do
      do_get
      response.should render_template(:new)
    end
  end

  describe 'GET reschedule/:id' do
    before :each do
      PixiPost.stub!(:reschedule).and_return( @post )
    end

    def do_get
      get :reschedule, :id => '1'
    end

    it "should reschedule the requested post" do
      do_get
      response.should be_success
    end

    it "should load the requested post" do
      PixiPost.stub(:reschedule).with('1').and_return(@post)
      do_get
    end

    it "should assign @post" do
      do_get
      assigns(:post).should_not be_nil
    end

    it "reschedule action should render reschedule template" do
      do_get
      response.should render_template(:reschedule)
    end

    it "responds to JSON" do
      @expected = { :post  => @post }.to_json
      get  :reschedule, :id => '1', format: :json
      response.body.should_not be_nil
    end
  end

  describe "POST create" do
    before do
      controller.stub!(:set_params).and_return(:success)
    end
    
    context 'failure' do
      
      before :each do
        PixiPost.stub!(:save).and_return(false)
      end

      def do_create
        post :create
      end

      it "should assign @post" do
        do_create
        assigns(:post).should_not be_nil 
      end

      it "should render the new template" do
        do_create
        response.should_not be_redirect
      end

      it "responds to JSON" do
        post :create, :format=>:json
	response.status.should_not eq(0)
      end
    end

    context 'success' do

      before :each do
        PixiPost.stub!(:save).and_return(true)
      end

      def do_create
        post :create, :pixi_post => { 'id'=>'test', 'description'=>'test' }
      end

      it "should load the requested post" do
        PixiPost.stub(:new).with({'id'=>'test', 'description'=>'test' }) { mock_post(:save => true) }
        do_create
      end

      it "should assign @post" do
        do_create
        assigns(:post).should_not be_nil 
      end

      it "redirects to the created post" do
        PixiPost.stub(:new).with({'id'=>'test', 'description'=>'test' }) { mock_post(:save => true) }
        do_create
        response.should be_redirect
      end

      it "should change post count" do
        lambda do
          do_create
          should change(PixiPost, :count).by(1)
        end
      end

      it "responds to JSON" do
        post :create, :pixi_post => { 'id'=>'test', 'description'=>'test' }, format: :json
	response.status.should_not eq(0)
      end
    end
  end

  describe "GET 'edit/:id'" do

    before :each do
      @post = stub_model(PixiPost)
      PixiPost.stub!(:find).and_return( @post )
    end

    def do_get
      get :edit, id: '1'
    end

    it "loads the requested post" do
      PixiPost.should_receive(:find).with('1').and_return(@post)
      do_get
    end

    it "assigns @post" do
      do_get
      assigns(:post).should_not be_nil 
    end

    it "loads the requested active post" do
      do_get
      response.should be_success
    end
  end

  describe 'GET index' do
    before(:each) do
      @posts = stub_model(PixiPost)
      PixiPost.stub!(:get_by_status).and_return(@posts)
      @posts.stub!(:paginate).and_return(@posts)
      controller.stub!(:load_data).and_return(:success)
      set_admin
      do_get
    end

    def do_get
      get :index, status: 'active'
    end

    it "renders the :index view" do
      response.should render_template :index
    end

    it "should assign @posts" do
      assigns(:posts).should == @posts
    end

    it "responds to JSON" do
      get :index, :format => 'json'
      expect(response).to be_success
    end
  end

  describe 'xhr GET index' do
    before(:each) do
      @posts = stub_model(PixiPost)
      PixiPost.stub!(:get_by_status).and_return(@posts)
      @posts.stub!(:paginate).and_return(@posts)
      controller.stub!(:load_data).and_return(:success)
      set_admin
      do_get
    end

    def do_get
      xhr :get, :index, status: 'active'
    end

    it "renders the :index view" do
      response.should render_template :index
    end

    it "should assign @posts" do
      assigns(:posts).should == @posts
    end
  end

  describe 'GET seller' do
    before :each do
      @posts = stub_model(PixiPost)
      PixiPost.stub_chain(:get_by_seller, :get_by_status).and_return( @posts )
      @posts.stub!(:paginate).and_return( @posts )
      do_get
    end

    def do_get
      get :seller, status: 'active'
    end

    it "renders the :seller view" do
      response.should render_template :seller
    end

    it "should assign @posts" do
      assigns(:posts).should_not be_nil
    end

    it "should show the requested posts" do
      response.should be_success
    end

    it "responds to JSON" do
      get :seller, format: :json
      expect(response).to be_success
    end
  end

  describe 'xhr GET seller' do
    before(:each) do
      @posts = stub_model(PixiPost)
      PixiPost.stub_chain(:get_by_seller, :get_by_status).and_return( @posts )
      @posts.stub!(:paginate).and_return( @posts )
      do_get
    end

    def do_get
      xhr :get, :seller, status: 'active'
    end

    it "renders the :seller view" do
      response.should render_template :seller
    end

    it "should assign @posts" do
      assigns(:posts).should_not be_nil
    end
  end

  describe 'GET pixter' do
    before :each do
      @posts = stub_model(PixiPost)
      PixiPost.stub_chain(:get_by_pixter, :get_by_status).and_return( @posts )
      @posts.stub!(:paginate).and_return( @posts )
      do_get
    end

    def do_get
      get :pixter, status: 'active'
    end

    it "renders the :pixter view" do
      response.should render_template :pixter
    end

    it "should assign @posts" do
      assigns(:posts).should_not be_nil
    end

    it "should show the requested posts" do
      response.should be_success
    end

    it "responds to JSON" do
      get :pixter, format: :json
      expect(response).to be_success
    end
  end

  describe 'xhr GET pixter' do
    before(:each) do
      @posts = stub_model(PixiPost)
      PixiPost.stub_chain(:get_by_pixter, :get_by_status).and_return( @posts )
      @posts.stub!(:paginate).and_return( @posts )
      do_get
    end

    def do_get
      xhr :get, :pixter, status: 'active'
    end

    it "renders the :pixter view" do
      response.should render_template :pixter
    end

    it "should assign @posts" do
      assigns(:posts).should_not be_nil
    end
  end

  describe "PUT /:id" do
    before (:each) do
      PixiPost.stub!(:find).and_return( @post )
      controller.stub!(:set_params).and_return(:success)
    end

    def do_update
      put :update, :id => "1", :pixi_post => {'id'=>'test', 'description' => 'test'}
    end

    context "with valid params" do
      before (:each) do
        @post.stub(:update_attributes).and_return(true)
      end

      it "should load the requested post" do
        PixiPost.stub(:find) { @post }
        do_update
      end

      it "should update the requested post" do
        PixiPost.stub(:find).with("1") { mock_post }
	mock_post.should_receive(:update_attributes).with({'id' => 'test', 'description' => 'test'})
        do_update
      end

      it "should assign @post" do
        PixiPost.stub(:find) { mock_post(:update_attributes => true) }
        do_update
        assigns(:post).should_not be_nil 
      end

      it "redirects to the updated post" do
        do_update
        response.should redirect_to @post
      end

      it "responds to JSON" do
        @expected = { :post  => @post }.to_json
        put :update, :id => "1", :pixi_post => {'id'=>'test', 'description' => 'test'}, format: :json
        response.body.should == @expected
      end
    end

    context "with invalid params" do
    
      before (:each) do
        @post.stub(:update_attributes).and_return(false)
      end

      it "should load the requested post" do
        PixiPost.stub(:find) { @post }
        do_update
      end

      it "should assign @post" do
        PixiPost.stub(:find) { mock_post(:update_attributes => false) }
        do_update
        assigns(:post).should_not be_nil 
      end

      it "renders the edit form" do 
        PixiPost.stub(:find) { mock_post(:update_attributes => false) }
        do_update
	response.should render_template(:edit)
      end

      it "responds to JSON" do
        put :update, :id => "1", :pixi_post => {'id'=>'test', 'description' => 'test'}, :format=>:json
	response.status.should_not eq(200)
      end
    end
  end

  describe "DELETE 'destroy'" do
    before (:each) do
      PixiPost.stub!(:find).and_return(@post)
    end

    def do_delete
      delete :destroy, :id => "37"
    end

    context 'success' do

      it "should load the requested post" do
        PixiPost.stub(:find).with("37").and_return(@post)
      end

      it "destroys the requested post" do
        PixiPost.stub(:find).with("37") { mock_post }
        mock_post.should_receive(:destroy)
        do_delete
      end

      it "redirects to the posts list" do
        PixiPost.stub(:find) { mock_post }
        do_delete
        response.should be_redirect
      end

      it "should decrement the PixiPost count" do
        lambda do
          do_delete
          should change(PixiPost, :count).by(-1)
        end
      end
    end
  end

  describe 'GET pixter_report' do
    before(:each) do
      @pixi_posts = mock("pixi_posts")
      PixiPost.stub!(:get_by_type).and_return(@pixi_posts)
      @pixi_posts.stub!(:paginate).and_return(@pixi_posts)
      controller.stub_chain(:init_vars, :set_pixter_id).and_return(:success)
      #@user.stub!(:is_pixter?).and_return(true)
    end

    def do_get
      get :pixter_report
    end

    it "renders the :pixter_report view" do
      do_get
      response.should render_template :pixter_report
    end

    it "exports CSV" do
      get :pixter_report, :format => 'csv'
      expect(response).to be_success
    end
  end
end
