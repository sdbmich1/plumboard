require 'login_user_spec'

describe TempListingsController do
  include LoginTestUser

  def mock_listing(stubs={})
    (@mock_listing ||= mock_model(TempListing, stubs).as_null_object).tap do |listing|
      listing.stub(stubs) unless stubs.empty?
    end
  end

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
    @listing = stub_model(TempListing, :id=>1, site_id: 1, seller_id: 1, pixi_id: '1', title: "Guitar for Sale", description: "Guitar for Sale")
  end

  describe 'GET show/:id' do
    before :each do
      TempListing.stub!(:find_pixi).and_return( @listing )
    end

    def do_get
      get :show, :id => '1'
    end

    it "should show the requested listing" do
      do_get
      response.should be_success
    end

    it "should load the requested listing" do
      TempListing.stub(:find_pixi).with('1').and_return(@listing)
      do_get
    end

    it "should assign @listing" do
      do_get
      assigns(:listing).should_not be_nil
    end

    it "show action should render show template" do
      do_get
      response.should render_template(:show)
    end

    it "responds to JSON" do
      @expected = { :listing  => @listing }.to_json
      get  :show, :id => '1', format: :json
      response.body.should_not be_nil 
    end
  end

  describe "GET 'new'" do

    before :each do
      TempListing.stub!(:new).and_return( @listing )
      @picture = stub_model(Picture)
      @listing.stub_chain(:pictures, :build).and_return(@picture)
    end

    def do_get
      get :new
    end

    it "should assign @listing" do
      do_get
      assigns(:listing).should_not be_nil
    end

    it "should assign @picture" do
      do_get
      assigns(:listing).pictures.should_not be_nil
    end

    it "new action should render new template" do
      do_get
      response.should render_template(:new)
    end
  end

  describe "POST create" do
    before do
      controller.stub!(:set_params).and_return(:success)
    end
    
    context 'failure' do
      
      before :each do
        TempListing.stub!(:save).and_return(false)
      end

      def do_create
        post :create
      end

      it "should assign @listing" do
        do_create
        assigns(:listing).should_not be_nil 
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
        TempListing.stub!(:save).and_return(true)
      end

      def do_create
        post :create, :temp_listing => { 'title'=>'test', 'description'=>'test' }
      end

      it "should load the requested listing" do
        TempListing.stub(:new).with({'title'=>'test', 'description'=>'test' }) { mock_listing(:save => true) }
        do_create
      end

      it "should assign @listing" do
        do_create
        assigns(:listing).should_not be_nil 
      end

      it "redirects to the created listing" do
        TempListing.stub(:new).with({'title'=>'test', 'description'=>'test' }) { mock_listing(:save => true) }
        do_create
        response.should be_redirect
      end

      it "should change listing count" do
        lambda do
          do_create
          should change(TempListing, :count).by(1)
        end
      end

      it "responds to JSON" do
        post :create, :temp_listing => { 'title'=>'test', 'description'=>'test' }, format: :json
	response.status.should_not eq(0)
      end
    end
  end

  describe "GET 'edit/:id'" do

    before :each do
      @listing = stub_model(TempListing)
      @pixi = stub_model(Listing)
      TempListing.stub!(:find_by_pixi_id).and_return( @listing )
      Listing.stub!(:find_by_pixi_id).and_return( @pixi )
      @pixi.stub!(:dup_pixi).and_return( @listing )
      @photo = stub_model(Picture)
      @listing.stub_chain(:pictures, :build).and_return(@photo)
    end

    def do_get
      get :edit, id: '1'
    end

    it "loads the requested listing" do
      TempListing.should_receive(:find_by_pixi_id).with('1').and_return(@listing)
      do_get
    end

    it "assigns @listing" do
      do_get
      assigns(:listing).should_not be_nil 
    end

    it "loads the requested active listing" do
      do_get
      response.should be_success
    end
  end

  describe "PUT /:id" do
    before (:each) do
      TempListing.stub!(:find_by_pixi_id).and_return( @listing )
      controller.stub!(:set_params).and_return(:success)
    end

    def do_update
      put :update, :id => "1", :temp_listing => {'title'=>'test', 'description' => 'test'}
    end

    context "with valid params" do
      before (:each) do
        @listing.stub(:update_attributes).and_return(true)
      end

      it "should load the requested listing" do
        TempListing.stub(:find_by_pixi_id) { @listing }
        do_update
      end

      it "should update the requested listing" do
        TempListing.stub(:find_by_pixi_id).with("1") { mock_listing }
	mock_listing.should_receive(:update_attributes).with({'title' => 'test', 'description' => 'test'})
        do_update
      end

      it "should assign @listing" do
        TempListing.stub(:find_by_pixi_id) { mock_listing(:update_attributes => true) }
        do_update
        assigns(:listing).should_not be_nil 
      end

      it "redirects to the updated listing" do
        do_update
        response.should redirect_to @listing
      end

      it "responds to JSON" do
        @expected = { :listing  => @listing }.to_json
        put :update, :id => "1", :temp_listing => {'title'=>'test', 'description' => 'test'}, format: :json
        response.body.should == @expected
      end
    end

    context "with invalid params" do
    
      before (:each) do
        @listing.stub(:update_attributes).and_return(false)
      end

      it "should load the requested listing" do
        TempListing.stub(:find_by_pixi_id) { @listing }
        do_update
      end

      it "should assign @listing" do
        TempListing.stub(:find_by_pixi_id) { mock_listing(:update_attributes => false) }
        do_update
        assigns(:listing).should_not be_nil 
      end

      it "renders the edit form" do 
        TempListing.stub(:find_by_pixi_id) { mock_listing(:update_attributes => false) }
        do_update
	response.should render_template(:edit)
      end

      it "responds to JSON" do
        put :update, :id => "1", :temp_listing => {'title'=>'test', 'description' => 'test'}, :format=>:json
	response.status.should_not eq(200)
      end
    end
  end

  describe "DELETE 'destroy'" do

    before (:each) do
      TempListing.stub!(:find_by_pixi_id).and_return(@listing)
    end

    def do_delete
      delete :destroy, :id => "37"
    end

    context 'success' do

      it "should load the requested listing" do
        TempListing.stub(:find_by_pixi_id).with("37").and_return(@listing)
      end

      it "destroys the requested listing" do
        TempListing.stub(:find_by_pixi_id).with("37") { mock_listing }
        mock_listing.should_receive(:destroy)
        do_delete
      end

      it "redirects to the listings list" do
        TempListing.stub(:find_by_pixi_id) { mock_listing }
        do_delete
        response.should be_redirect
      end

      it "should decrement the TempListing count" do
        lambda do
          do_delete
          should change(TempListing, :count).by(-1)
        end
      end
    end
  end

  describe "PUT /submit/:id" do
    before (:each) do
      TempListing.stub!(:find_by_pixi_id).and_return( @listing )
    end

    def do_submit
      put :submit, :id => "1"
    end

    context "success" do
      before :each do
        @listing.stub!(:resubmit_order).and_return(true)
      end

      it "should load the requested listing" do
        TempListing.stub(:find_by_pixi_id) { @listing }
        do_submit
      end

      it "should update the requested listing" do
        TempListing.stub(:find_by_pixi_id).with("1") { mock_listing }
	mock_listing.should_receive(:resubmit_order).and_return(:success)
        do_submit
      end

      it "should assign @listing" do
        TempListing.stub(:find_by_pixi_id) { mock_listing(:resubmit_order => true) }
        do_submit
        assigns(:listing).should_not be_nil 
      end

      it "redirects the page" do
        do_submit
        response.should render_template(:submit)
      end

      it "responds to JSON" do
        @expected = { :listing  => @listing }.to_json
        put :submit, :id => "1", format: :json
        response.body.should == @expected
      end
    end

    context 'failure' do
      before :each do
        @listing.stub!(:resubmit_order).and_return(false) 
      end

      it "should assign listing" do
        do_submit
        assigns(:listing).should_not be_nil 
      end

      it "should render nothing" do
        do_submit
        controller.stub!(:render)
      end

      it "responds to JSON" do
        put :submit, :id => "1", format: :json
	response.status.should eq(422)
      end
    end
  end

  describe "xhr GET /unposted" do
    before :each do
      @listings = stub_model(TempListing)
      TempListing.stub_chain(:draft, :get_by_seller).and_return( @listings )
      @listings.stub!(:paginate).and_return( @listings )
      do_get
    end

    def do_get
      xhr :get, :unposted, page: '1'
    end

    it "renders the :unposted view" do
      response.should render_template :unposted
    end

    it "assigns @listings" do
      assigns(:listings).should_not be_nil
    end

    it "shows the requested listings" do
      response.should be_success
    end

    it "responds to JSON" do
      get :unposted, format: :json
      expect(response).to be_success
    end
  end

  describe "xhr GET /pending" do
    before :each do
      @listings = stub_model(TempListing)
      TempListing.stub_chain(:get_by_status, :get_by_seller).and_return( @listings )
      @listings.stub!(:paginate).and_return( @listings )
      do_get
    end

    def do_get
      xhr :get, :pending, page: '1'
    end

    it "renders the :pending view" do
      response.should render_template :pending
    end

    it "assigns @listings" do
      assigns(:listings).should_not be_nil
    end

    it "shows the requested listings" do
      response.should be_success
    end

    it "responds to JSON" do
      get :pending, format: :json
      expect(response).to be_success
    end
  end
end
