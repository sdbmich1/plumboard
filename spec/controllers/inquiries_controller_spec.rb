require 'login_user_spec'

describe InquiriesController do
  include LoginTestUser

  def mock_inquiry(stubs={})
    (@mock_inquiry ||= mock_model(Inquiry, stubs).as_null_object).tap do |inquiry|
      inquiry.stub(stubs) unless stubs.empty?
    end
  end

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
    @user = mock_user
    @inquiry = stub_model(Inquiry, :id=>1, user_id: 12, first_name: 'Al', last_name: 'Test', email: 'atest@test.com', comments: "Guitar for Sale")
  end

  describe 'GET index' do

    before :each do
      @inquiries = stub_model(Inquiry)
      Inquiry.stub!(:active).and_return(@inquiries)
      @inquiries.stub!(:paginate).and_return( @inquiries )
      do_get
    end

    def do_get
      get :index
    end

    it "assigns @inquiries" do
      assigns(:inquiries).should_not be_nil
    end

    it "renders the :index view" do
      response.should render_template :index
    end

    it "shows the requested inquiries" do
      response.should be_success
    end
  end

  describe "GET 'new'" do

    before :each do
      controller.stub!(:current_user).and_return(@user)
      @user.stub_chain(:inquiries, :build).and_return( @inquiry )
      do_get
    end

    def do_get
      get :new
    end

    it "should assign @inquiry" do
      assigns(:inquiry).should_not be_nil
    end

    it "renders the :new view" do
      response.should render_template :new
    end
  end

  describe 'GET show' do
    before :each do
      Invoice.stub!(:find).and_return( @invoice )
      do_get
    end

    def do_get
      get :show, id: '1'
    end

    it "renders the :show view" do
      response.should render_template :show
    end

    it "should load the requested invoice" do
      Inquiry.should_receive(:find).with('1').and_return(@inquiry)
      do_get
    end

    it "should assign @inquiry" do
      assigns(:inquiry).should_not be_nil
    end

    it "shows the requested inquiry" do
      response.should be_success
    end
  end

  describe "GET 'edit/:id'" do

    before :each do
      Inquiry.stub!(:find).and_return( @inquiry )
    end

    def do_get
      get :edit, id: '1'
    end

    it "should load the requested inquiry" do
      Inquiry.should_receive(:find).with('1').and_return(@inquiry)
      do_get
    end

    it "should assign @inquiry" do
      do_get
      assigns(:inquiry).should_not be_nil 
    end

    it "should load the requested inquiry" do
      do_get
      response.should be_success
    end
  end

  describe "PUT /:id" do
    before (:each) do
      Inquiry.stub!(:find).and_return( @inquiry )
    end

    def do_update
      put :update, :id => "1", :inquiry => {'email'=>'test', 'comments' => 'test'}
    end

    context "with valid params" do
      before (:each) do
        @inquiry.stub(:update_attributes).and_return(true)
      end

      it "should load the requested inquiry" do
        Inquiry.stub(:find) { @inquiry }
        do_update
      end

      it "should update the requested inquiry" do
        Inquiry.stub(:find).with("1") { mock_inquiry }
	mock_inquiry.should_receive(:update_attributes).with({'email' => 'test', 'comments' => 'test'})
        do_update
      end

      it "should assign @inquiry" do
        Inquiry.stub(:find) { mock_inquiry(:update_attributes => true) }
        do_update
        assigns(:inquiry).should_not be_nil 
      end

      it "redirects to the updated inquiry" do
        do_update
        response.should redirect_to @inquiry
      end
    end

    context "with invalid params" do
    
      before (:each) do
        @inquiry.stub(:update_attributes).and_return(false)
      end

      it "should load the requested inquiry" do
        Inquiry.stub(:find) { @inquiry }
        do_update
      end

      it "should assign @inquiry" do
        Inquiry.stub(:find) { mock_inquiry(:update_attributes => false) }
        do_update
        assigns(:inquiry).should_not be_nil 
      end

      it "renders the edit form" do 
        Inquiry.stub(:find) { mock_inquiry(:update_attributes => false) }
        do_update
	response.should render_template(:edit)
      end
    end
  end

  describe "POST create" do
    context 'failure' do
      
      before :each do
        Inquiry.stub!(:save).and_return(false)
      end

      def do_create
        post :create
      end

      it "should assign @inquiry" do
        do_create
        assigns(:inquiry).should_not be_nil 
      end

      it "should render the new template" do
        do_create
        response.should render_template(:new)
      end

      it "responds to JSON" do
        post :create, :format=>:json
	response.status.should_not eq(200)
      end
    end

    context 'success' do

      before :each do
        Inquiry.stub!(:save).and_return(true)
      end

      def do_create
        post :create, :inquiry => { 'email'=>'test', 'comments'=>'test' }
      end

      it "should load the requested inquiry" do
        Inquiry.stub(:new).with({'email'=>'test', 'comments'=>'test' }) { mock_inquiry(:save => true) }
        do_create
      end

      it "should assign @inquiry" do
        do_create
        assigns(:inquiry).should_not be_nil 
      end

      it "redirects to the created inquiry" do
        Inquiry.stub(:new).with({'email'=>'test', 'comments'=>'test' }) { mock_inquiry(:save => true) }
        do_create
        response.should be_redirect
      end

      it "should change inquiry count" do
        lambda do
          do_create
          should change(Inquiry, :count).by(1)
        end
      end

      it "responds to JSON" do
        post :create, :inquiry => { 'email'=>'test', 'comments'=>'test' }, format: :json
	response.status.should_not eq(0)
      end
    end
  end

  describe "DELETE 'destroy'" do

    before (:each) do
      Inquiry.stub!(:find).and_return(@inquiry)
    end

    def do_delete
      delete :destroy, :id => "37"
    end

    context 'success' do

      it "should load the requested inquiry" do
        Inquiry.stub(:find).with("37").and_return(@inquiry)
      end

      it "destroys the requested inquiry" do
        Inquiry.stub(:find).with("37") { mock_inquiry }
        mock_inquiry.should_receive(:destroy)
        do_delete
      end

      it "redirects to the inquiries list" do
        Inquiry.stub(:find) { mock_inquiry }
        do_delete
        response.should be_redirect
      end

      it "should decrement the Inquiry count" do
        lambda do
          do_delete
          should change(Inquiry, :count).by(-1)
        end
      end
    end
  end

end
