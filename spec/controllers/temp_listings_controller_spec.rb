require 'login_user_spec'

describe TempListingsController do
  include LoginTestUser

  def mock_listing(stubs={})
    (@mock_listing ||= mock_model(TempListing, stubs).as_null_object).tap do |listing|
      allow(listing).to receive_messages(stubs) unless stubs.empty?
    end
  end

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      allow(user).to receive_messages(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
    @listing = stub_model(TempListing, :id=>1, site_id: 1, seller_id: 1, pixi_id: '1', title: "Guitar for Sale", description: "Guitar for Sale")
  end

  describe 'GET show/:id' do
    before :each do
      allow(TempListing).to receive(:find_by_pixi_id).and_return( @listing )
    end

    def do_get
      get :show, :id => '1'
    end

    it "should show the requested listing" do
      do_get
      expect(response).to be_success
    end

    it "should load the requested listing" do
      allow(TempListing).to receive(:find_by_pixi_id).with('1').and_return(@listing)
      do_get
    end

    it "should assign @listing" do
      do_get
      expect(assigns(:listing)).not_to be_nil
    end

    it "show action should render show template" do
      do_get
      expect(response).to render_template(:show)
    end

    it "responds to JSON" do
      @expected = { :listing  => @listing }.to_json
      get  :show, :id => '1', format: :json
      expect(response.body).not_to be_nil 
    end
  end

  describe "GET 'new'" do

    before :each do
      allow(TempListing).to receive(:new).and_return( @listing )
    end

    def do_get
      get :new
    end

    it "should assign @listing" do
      do_get
      expect(assigns(:listing)).not_to be_nil
    end

    it "new action should render new template" do
      do_get
      expect(response).to render_template(:new)
    end
  end

  describe "POST create" do
    before do
      allow(TempListing).to receive(:add_listing).and_return( @listing )
      allow(@listing).to receive_message_chain(:user, :guest?).and_return( session )
      allow(controller).to receive(:current_user).and_return(@user)
      allow(controller).to receive_message_chain(:set_params, :set_uid).and_return(:success)
    end
    
    context 'failure' do
      
      before :each do
        allow(TempListing).to receive(:save).and_return(false)
      end

      def do_create
        post :create
      end

      it "should assign @listing" do
        do_create
        expect(assigns(:listing)).not_to be_nil 
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
        allow(TempListing).to receive(:save).and_return(true)
      end

      def do_create
        post :create, :temp_listing => { 'title'=>'test', 'description'=>'test' }
      end

      it "should load the requested listing" do
        allow(TempListing).to receive(:new).with({'title'=>'test', 'description'=>'test' }) { mock_listing(:save => true) }
        do_create
      end

      it "should assign @listing" do
        do_create
        expect(assigns(:listing)).not_to be_nil 
      end

      it "redirects to the created listing" do
        allow(TempListing).to receive(:add_listing).with({'title'=>'test', 'description'=>'test'}, @user) { mock_listing(:save => true) }
        do_create
        expect(response).to be_redirect
      end

      it "should change listing count" do
        lambda do
          do_create
          is_expected.to change(TempListing, :count).by(1)
        end
      end

      it "responds to JSON" do
        post :create, :temp_listing => { 'title'=>'test', 'description'=>'test' }, format: :json
	expect(response.status).not_to eq(0)
      end
    end
  end

  describe "GET 'edit/:id'" do

    before :each do
      @listing = stub_model(TempListing)
      @pixi = stub_model(Listing)
      allow(TempListing).to receive(:find_by_pixi_id).and_return( @listing )
      allow(Listing).to receive(:find_by_pixi_id).and_return( @pixi )
      allow(@pixi).to receive(:dup_pixi).and_return( @listing )
    end

    def do_get
      get :edit, id: '1'
    end

    it "loads the requested listing" do
      expect(TempListing).to receive(:find_by_pixi_id).with('1').and_return(@listing)
      do_get
    end

    it "assigns @listing" do
      do_get
      expect(assigns(:listing)).not_to be_nil 
    end

    it "loads the requested active listing" do
      do_get
      expect(response).to be_success
    end
  end

  describe "PUT /:id" do
    before (:each) do
      allow(TempListing).to receive(:find_by_pixi_id).and_return( @listing )
      allow(controller).to receive(:set_params).and_return(:success)
    end

    def do_update
      put :update, :id => "1", :temp_listing => {'title'=>'test', 'description' => 'test'}
    end

    context "with valid params" do
      before (:each) do
        allow(@listing).to receive(:update_attributes).and_return(true)
      end

      it "should load the requested listing" do
        allow(TempListing).to receive(:find_by_pixi_id) { @listing }
        do_update
      end

      it "should update the requested listing" do
        allow(TempListing).to receive(:find_by_pixi_id).with("1") { mock_listing }
	expect(mock_listing).to receive(:update_attributes).with({'title' => 'test', 'description' => 'test'})
        do_update
      end

      it "should assign @listing" do
        allow(TempListing).to receive(:find_by_pixi_id) { mock_listing(:update_attributes => true) }
        do_update
        expect(assigns(:listing)).not_to be_nil 
      end

      it "redirects to the updated listing" do
        do_update
        expect(response).to redirect_to @listing
      end

      it "responds to JSON" do
        @expected = { :listing  => @listing }.to_json
        put :update, :id => "1", :temp_listing => {'title'=>'test', 'description' => 'test'}, format: :json
        expect(response.body).to eq(@expected)
      end
    end

    context "with invalid params" do
    
      before (:each) do
        allow(@listing).to receive(:update_attributes).and_return(false)
      end

      it "should load the requested listing" do
        allow(TempListing).to receive(:find_by_pixi_id) { @listing }
        do_update
      end

      it "should assign @listing" do
        allow(TempListing).to receive(:find_by_pixi_id) { mock_listing(:update_attributes => false) }
        do_update
        expect(assigns(:listing)).not_to be_nil 
      end

      it "renders the edit form" do 
        allow(TempListing).to receive(:find_by_pixi_id) { mock_listing(:update_attributes => false) }
        do_update
	expect(response).to render_template(:edit)
      end

      it "responds to JSON" do
        put :update, :id => "1", :temp_listing => {'title'=>'test', 'description' => 'test'}, :format=>:json
	expect(response.status).not_to eq(200)
      end
    end
  end

  describe "DELETE 'destroy'" do

    before (:each) do
      allow(TempListing).to receive(:find_by_pixi_id).and_return(@listing)
    end

    def do_delete
      delete :destroy, :id => "37"
    end

    context 'success' do

      it "should load the requested listing" do
        allow(TempListing).to receive(:find_by_pixi_id).with("37").and_return(@listing)
      end

      it "destroys the requested listing" do
        allow(TempListing).to receive(:find_by_pixi_id).with("37") { mock_listing }
        expect(mock_listing).to receive(:destroy)
        do_delete
      end

      it "redirects to the listings list" do
        allow(TempListing).to receive(:find_by_pixi_id) { mock_listing }
        allow(mock_listing).to receive(:destroy).and_return(true)
        do_delete
        expect(response).to be_redirect
      end

      it "should decrement the TempListing count" do
        lambda do
          do_delete
          is_expected.to change(TempListing, :count).by(-1)
        end
      end
    end
  end

  describe "PUT /submit/:id" do
    before (:each) do
      allow(TempListing).to receive(:find_by_pixi_id).and_return( @listing )
    end

    def do_submit
      put :submit, :id => "1"
    end

    context "success" do
      before :each do
        allow(@listing).to receive(:resubmit_order).and_return(true)
      end

      it "should load the requested listing" do
        allow(TempListing).to receive(:find_by_pixi_id) { @listing }
        do_submit
      end

      it "should update the requested listing" do
        allow(TempListing).to receive(:find_by_pixi_id).with("1") { mock_listing }
	expect(mock_listing).to receive(:resubmit_order).and_return(:success)
        do_submit
      end

      it "should assign @listing" do
        allow(TempListing).to receive(:find_by_pixi_id) { mock_listing(:resubmit_order => true) }
        do_submit
        expect(assigns(:listing)).not_to be_nil 
      end

      it "redirects the page" do
        do_submit
        expect(response).to render_template(:submit)
      end

      it "responds to JSON" do
        @expected = { :listing  => @listing }.to_json
        put :submit, :id => "1", format: :json
        expect(response.body).to eq(@expected)
      end
    end

    context 'failure' do
      before :each do
        allow(@listing).to receive(:resubmit_order).and_return(false) 
      end

      it "should assign listing" do
        do_submit
        expect(assigns(:listing)).not_to be_nil 
      end

      it "should render nothing" do
        do_submit
        allow(controller).to receive(:render)
      end

      it "responds to JSON" do
        put :submit, :id => "1", format: :json
	expect(response.status).to eq(422)
      end
    end
  end

  describe "xhr GET /unposted" do
    before :each do
      @listings = stub_model(TempListing)
      allow(TempListing).to receive_message_chain(:draft, :get_by_seller).and_return( @listings )
      allow(@listings).to receive(:paginate).and_return( @listings )
      do_get
    end

    def do_get
      xhr :get, :unposted, page: '1'
    end

    it "renders the :unposted view" do
      expect(response).to render_template :unposted
    end

    it "assigns @listings" do
      expect(assigns(:listings)).not_to be_nil
    end

    it "shows the requested listings" do
      expect(response).to be_success
    end

    it "responds to JSON" do
      get :unposted, format: :json
      expect(response).to be_success
    end
  end

  describe "xhr GET /pending" do
    before :each do
      @listings = stub_model(TempListing)
      allow(TempListing).to receive_message_chain(:get_by_status, :get_by_seller).and_return( @listings )
      allow(@listings).to receive(:paginate).and_return( @listings )
      do_get
    end

    def do_get
      xhr :get, :pending, page: '1'
    end

    it "renders the :pending view" do
      expect(response).to render_template :pending
    end

    it "assigns @listings" do
      expect(assigns(:listings)).not_to be_nil
    end

    it "shows the requested listings" do
      expect(response).to be_success
    end

    it "responds to JSON" do
      get :pending, format: :json
      expect(response).to be_success
    end
  end
end
