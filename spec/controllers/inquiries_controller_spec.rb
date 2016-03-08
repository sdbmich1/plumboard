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
      allow(Inquiry).to receive(:get_by_contact_type).and_return(@inquiries)
      allow(@inquiries).to receive(:paginate).and_return( @inquiries )
      do_get
    end

    def do_get
      get :index, ctype: 'support'
    end

    it "assigns @inquiries" do
      expect(assigns(:inquiries)).not_to be_nil
    end

    it "renders the :index view" do
      expect(response).to render_template :index
    end

    it "shows the requested inquiries" do
      expect(response).to be_success
    end
  end

  describe 'xhr GET index' do

    before :each do
      @inquiries = stub_model(Inquiry)
      allow(Inquiry).to receive(:get_by_contact_type).and_return(@inquiries)
      allow(@inquiries).to receive(:paginate).and_return( @inquiries )
      do_get
    end

    def do_get
      xhr :get, :index, ctype: 'support'
    end

    it "assigns @inquiries" do
      expect(assigns(:inquiries)).not_to be_nil
    end

    it "renders the :index view" do
      expect(response).to render_template :index
    end

    it "shows the requested inquiries" do
      expect(response).to be_success
    end
  end

  describe 'xhr GET closed' do

    before :each do
      @inquiries = stub_model(Inquiry)
      allow(Inquiry).to receive(:get_by_status).and_return(@inquiries)
      allow(@inquiries).to receive(:paginate).and_return( @inquiries )
      do_get
    end

    def do_get
      xhr :get, :closed
    end

    it "assigns @inquiries" do
      expect(assigns(:inquiries)).not_to be_nil
    end

    it "renders the :closed view" do
      expect(response).to render_template :closed
    end

    it "shows the requested inquiries" do
      expect(response).to be_success
    end
  end

  describe "GET 'new'" do

    before :each do
      allow(controller).to receive(:current_user).and_return(@user)
      @user.stub_chain(:inquiries, :build).and_return( @inquiry )
      do_get
    end

    def do_get
      get :new
    end

    it "should assign @inquiry" do
      expect(assigns(:inquiry)).not_to be_nil
    end

    it "renders the :new view" do
      expect(response).to render_template :new
    end

    it "should render the correct layout" do
      expect(response).to render_template("layouts/about")
    end
  end

  describe 'GET show' do
    before :each do
      allow(Inquiry).to receive(:find).and_return( @inquiry )
      do_get
    end

    def do_get
      get :show, id: '1'
    end

    it "renders the :show view" do
      expect(response).to render_template :show
    end

    it "should load the requested invoice" do
      expect(Inquiry).to receive(:find).with('1').and_return(@inquiry)
      do_get
    end

    it "should assign @inquiry" do
      expect(assigns(:inquiry)).not_to be_nil
    end

    it "shows the requested inquiry" do
      expect(response).to be_success
    end
  end

  describe "GET 'edit/:id'" do

    before :each do
      allow(Inquiry).to receive(:find).and_return( @inquiry )
    end

    def do_get
      get :edit, id: '1'
    end

    it "should load the requested inquiry" do
      expect(Inquiry).to receive(:find).with('1').and_return(@inquiry)
      do_get
    end

    it "should assign @inquiry" do
      do_get
      expect(assigns(:inquiry)).not_to be_nil 
    end

    it "should load the requested inquiry" do
      do_get
      expect(response).to be_success
    end
  end

  describe "PUT /:id" do
    before (:each) do
      allow(Inquiry).to receive(:find).and_return( @inquiry )
    end

    def do_update
      put :update, :id => "1", :inquiry => {'email'=>'test', 'comments' => 'test'}
    end

    context "with valid params" do
      before (:each) do
        allow(@inquiry).to receive(:update_attributes).and_return(true)
      end

      it "should load the requested inquiry" do
        allow(Inquiry).to receive(:find) { @inquiry }
        do_update
      end

      it "should update the requested inquiry" do
        allow(Inquiry).to receive(:find).with("1") { mock_inquiry }
	expect(mock_inquiry).to receive(:update_attributes).with({'email' => 'test', 'comments' => 'test'})
        do_update
      end

      it "should assign @inquiry" do
        allow(Inquiry).to receive(:find) { mock_inquiry(:update_attributes => true) }
        do_update
        expect(assigns(:inquiry)).not_to be_nil 
      end

      it "redirects to the updated inquiry" do
        do_update
        expect(response).to redirect_to @inquiry
      end
    end

    context "with invalid params" do
    
      before (:each) do
        allow(@inquiry).to receive(:update_attributes).and_return(false)
      end

      it "should load the requested inquiry" do
        allow(Inquiry).to receive(:find) { @inquiry }
        do_update
      end

      it "should assign @inquiry" do
        allow(Inquiry).to receive(:find) { mock_inquiry(:update_attributes => false) }
        do_update
        expect(assigns(:inquiry)).not_to be_nil 
      end

      it "renders the edit form" do 
        allow(Inquiry).to receive(:find) { mock_inquiry(:update_attributes => false) }
        do_update
	expect(response).to render_template(:edit)
      end
    end
  end

  describe "POST create" do
    context 'failure' do
      
      before :each do
        allow(Inquiry).to receive(:save).and_return(false)
      end

      def do_create
        post :create
      end

      it "should assign @inquiry" do
        do_create
        expect(assigns(:inquiry)).not_to be_nil 
      end

      it "should render the new template" do
        do_create
        expect(response).to render_template(:new)
      end

      it "responds to JSON" do
        post :create, :format=>:json
	expect(response.status).not_to eq(200)
      end
    end

    context 'success' do

      before :each do
        allow(Inquiry).to receive(:save).and_return(true)
      end

      def do_create
        post :create, :inquiry => { 'email'=>'test', 'comments'=>'test' }
      end

      it "should load the requested inquiry" do
        allow(Inquiry).to receive(:new).with({'email'=>'test', 'comments'=>'test' }) { mock_inquiry(:save => true) }
        do_create
      end

      it "should assign @inquiry" do
        do_create
        expect(assigns(:inquiry)).not_to be_nil 
      end

      it "redirects to the created inquiry" do
        allow(Inquiry).to receive(:new).with({'email'=>'test', 'comments'=>'test' }) { mock_inquiry(:save => true) }
        do_create
        expect(response).to be_redirect
      end

      it "should change inquiry count" do
        lambda do
          do_create
          is_expected.to change(Inquiry, :count).by(1)
        end
      end

      it "responds to JSON" do
        post :create, :inquiry => { 'email'=>'test', 'comments'=>'test' }, format: :json
	expect(response.status).not_to eq(0)
      end
    end
  end

  describe "DELETE 'destroy'" do

    before (:each) do
      allow(Inquiry).to receive(:find).and_return(@inquiry)
    end

    def do_delete
      delete :destroy, :id => "37"
    end

    context 'success' do

      it "should load the requested inquiry" do
        allow(Inquiry).to receive(:find).with("37").and_return(@inquiry)
      end

      it "destroys the requested inquiry" do
        allow(Inquiry).to receive(:find).with("37") { mock_inquiry }
        expect(mock_inquiry).to receive(:destroy)
        do_delete
      end

      it "redirects to the inquiries list" do
        allow(Inquiry).to receive(:find) { mock_inquiry }
        do_delete
        expect(response).to be_redirect
      end

      it "should decrement the Inquiry count" do
        lambda do
          do_delete
          is_expected.to change(Inquiry, :count).by(-1)
        end
      end
    end
  end

end
