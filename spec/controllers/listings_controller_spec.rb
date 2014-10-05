require 'login_user_spec'

describe ListingsController do
  include LoginTestUser

  def mock_listing(stubs={})
    (@mock_listing ||= mock_model(Listing, stubs).as_null_object).tap do |listing|
      listing.stub(stubs) unless stubs.empty?
    end
  end

  def mock_temp_listing(stubs={})
    (@mock_temp_listing ||= mock_model(TempListing, stubs).as_null_object).tap do |temp_listing|
      temp_listing.stub(stubs) unless stubs.empty?
    end
  end

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  def mock_comment(stubs={})
    (@mock_comment ||= mock_model(Comment, stubs).as_null_object).tap do |comment|
      comment.stub(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
    @user = mock_user
    @listing = stub_model(Listing, :id=>1, pixi_id: '1', site_id: 1, seller_id: 1, title: "Guitar for Sale", description: "Guitar for Sale")
  end

  describe 'GET index' do
    before(:each) do
      @listings = stub_model(Listing)
      Listing.stub_chain(:get_by_status).and_return(@listings)
      @listings.stub!(:paginate).and_return( @listings )
      controller.stub_chain(:load_data, :get_location).and_return(:success)
      do_get
    end

    def do_get
      get :index
    end

    it "renders the :index view" do
      response.should render_template :index
    end

    it "should assign @listings" do
      assigns(:listings).should_not be_nil
    end

    it "should render the correct layout" do
      response.should render_template("layouts/application")
    end

    it "responds to JSON" do
      get :index, :format => 'json'
      expect(response).to be_success
    end
  end

  describe 'xhr GET index' do
    before(:each) do
      @listings = mock("listings")
      Listing.stub_chain(:get_by_status).and_return(@listings)
      @listings.stub!(:paginate).and_return( @listings )
      controller.stub_chain(:load_data, :get_location).and_return(:success)
      do_get
    end

    def do_get
      xhr :get, :index
    end

    it "renders the :index view" do
      response.should render_template :index
    end

    it "should assign @listings" do
      assigns(:listings).should_not be_nil
    end
  end

  describe 'GET category' do
    before(:each) do
      @listings = stub_model(Listing)
      @category = stub_model Category
      Listing.stub!(:get_by_city).and_return(@listings)
      Category.stub!(:find).and_return(@category)
      controller.stub!(:load_data).and_return(:success)
      do_get
    end

    def do_get
      xhr :get, :category, cid: '1', loc: '1'
    end

    it "should load the requested category" do
      Category.stub(:find).with('1').and_return(@category)
      do_get
    end     
			                   
    it "should assign @category" do
      do_get
      assigns(:category).should_not be_nil
    end

    it "renders the :category view" do
      response.should render_template :category
    end

    it "assigns @listings" do
      assigns(:listings).should == @listings
    end

    it "responds to JSON" do
      get :category, cid: '1', loc: '1', format: :json
      expect(response).to be_success
    end
  end

  describe 'GET local' do
    before(:each) do
      @listings = stub_model(Listing)
      Listing.stub!(:get_by_city).and_return(@listings)
      controller.stub!(:load_data).and_return(:success)
      do_get
    end

    def do_get
      xhr :get, :local, loc: '1'
    end

    it "renders the :local view" do
      response.should render_template :local
    end

    it "assigns @listings" do
      assigns(:listings).should == @listings
    end

    it "responds to JSON" do
      get :local, loc: '1', format: :json
      expect(response).to be_success
    end
  end

  describe 'GET seller' do
    before :each do
      @listings = stub_model(Listing)
      Listing.stub_chain(:active, :get_by_seller).and_return( @listings )
      @listings.stub!(:paginate).and_return( @listings )
      do_get
    end

    def do_get
      get :seller
    end

    it "renders the :seller view" do
      response.should render_template :seller
    end

    it "should assign @listings" do
      assigns(:listings).should_not be_nil
    end

    it "should show the requested listings" do
      response.should be_success
    end

    it "responds to JSON" do
      @expected = { :listings  => @listings }.to_json
      get :seller, format: :json
      expect(response).to be_success
      response.body.should_not be_nil
    end
  end

  describe 'GET sold' do
    before :each do
      @listings = stub_model(Listing)
      Listing.stub_chain(:get_by_seller, :get_by_status).and_return( @listings )
      @listings.stub!(:paginate).and_return( @listings )
      do_get
    end

    def do_get
      xhr :get, :sold
    end

    it "renders the :sold view" do
      response.should render_template :sold
    end

    it "should assign @listings" do
      assigns(:listings).should_not be_nil
    end

    it "should show the requested listings" do
      response.should be_success
    end

    it "responds to JSON" do
      get :sold, format: :json
      expect(response).to be_success
    end
  end

  describe 'GET wanted' do
    before :each do
      @listings = stub_model(Listing)
      controller.stub!(:current_user).and_return(@user)
      Listing.stub!(:wanted_list).and_return( @listings )
      do_get
    end

    def do_get
      xhr :get, :wanted
    end

    it "renders the :wanted view" do
      response.should render_template :wanted
    end

    it "should assign @user" do
      assigns(:user).should_not be_nil
    end

    it "should assign @listings" do
      assigns(:listings).should_not be_nil
    end

    it "should show the requested listings" do
      response.should be_success
    end

    it "responds to JSON" do
      get :wanted, format: :json
      expect(response).to be_success
    end
  end

  describe 'GET purchased' do
    before :each do
      @listings = stub_model(Listing)
      Listing.stub_chain(:get_by_buyer, :get_by_status).and_return( @listings )
      @listings.stub!(:paginate).and_return( @listings )
      do_get
    end

    def do_get
      xhr :get, :purchased
    end

    it "renders the :purchased view" do
      response.should render_template :purchased
    end

    it "should assign @listings" do
      assigns(:listings).should_not be_nil
    end

    it "should show the requested listings" do
      response.should be_success
    end

    it "responds to JSON" do
      get :purchased, format: :json
      expect(response).to be_success
    end
  end

  describe 'GET show/:id' do
    before :each do
      @comments = mock('comments')
      Listing.stub_chain(:find_pixi).with('1').and_return( @listing )
      @listing.stub_chain(:comments, :build).and_return( @comments )
      controller.stub!(:load_comments).and_return(@comments)
      controller.stub!(:add_points).and_return(:success)
    end

    def do_get
      get :show, :id => '1'
    end

    it "should show the requested listing" do
      do_get
      response.should be_success
    end

    it "should load the requested listing" do
      Listing.stub(:find_pixi).with('1').and_return(@listing)
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
      get :show, :id => '1', :format => :json
      expect(response).to be_success
    end
  end

  describe 'xhr GET show/:id' do
    before :each do
      @comments = stub_model(Comment)
      Listing.stub!(:find_pixi).with('1').and_return( @listing )
      @listing.stub_chain(:comments, :build).and_return( @comments )
      controller.stub!(:load_comments).and_return(:success)
      controller.stub!(:add_points).and_return(:success)
    end

    def do_get
      xhr :get, :show, :id => '1'
    end

    it "should show the requested listing" do
      do_get
      response.should be_success
    end

    it "should load the requested listing" do
      Listing.stub(:find_pixi).with('1').and_return(@listing)
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
  end

  describe "DELETE 'destroy'" do

    before (:each) do
      Listing.stub!(:find_by_pixi_id).and_return(@listing)
    end

    def do_delete
      delete :destroy, :id => "37"
    end

    context 'success' do

      it "should load the requested listing" do
        Listing.stub(:find_by_pixi_id).with("37").and_return(@listing)
      end

      it "destroys the requested listing" do
        Listing.stub(:find_by_pixi_id).with("37") { mock_listing }
        mock_listing.should_receive(:destroy)
        do_delete
      end

      it "redirects to the listings list" do
        Listing.stub(:find_by_pixi_id) { mock_listing }
        do_delete
        response.should be_redirect
      end

      it "should decrement the Listing count" do
        lambda do
          do_delete
          should change(Listing, :count).by(-1)
        end
      end
    end
  end

  describe 'xhr GET pixi_price' do
    before :each do
      @listing = mock_listing
      Listing.stub_chain(:find_by_pixi_id, :price).and_return( @listing )
      @listing.stub(:price) {'500.00'}
      do_get
    end

    def do_get
      xhr :get, :pixi_price, pixi_id: '1'
    end

    it "should load nothing" do
      controller.stub!(:render)
    end

    it "should assign @price" do
      assigns(:price).should_not be_nil
    end

    it "should show the requested listing price" do
      response.should be_success
    end

    it "responds to JSON" do
      get :pixi_price, :pixi_id => '1', :format => :json
      expect(response).to be_success
    end
  end

  describe "PUT /:id" do
    before (:each) do
      Listing.stub!(:find_by_pixi_id).and_return( @listing )
    end

    def do_update
      put :update, :id => "1", reason: 'test'
    end

    context "with valid params" do
      before (:each) do
        @listing.stub(:update_attributes).and_return(true)
      end

      it "should load the requested listing" do
        Listing.stub(:find_by_pixi_id) { @listing }
        do_update
      end

      it "should update the requested listing" do
        Listing.stub(:find_by_pixi_id).with("1") { mock_listing }
	mock_listing.should_receive(:update_attributes).with({:explanation=>"test", :status=>"removed"})
        do_update
      end

      it "should assign @listing" do
        Listing.stub(:find_by_pixi_id) { mock_listing(:update_attributes => true) }
        do_update
        assigns(:listing).should_not be_nil 
      end

      it "redirects to the updated listing" do
        do_update
        response.should be_redirect
      end
    end

    context "with invalid params" do
    
      before (:each) do
        @listing.stub(:update_attributes).and_return(false)
      end

      it "should load the requested listing" do
        Listing.stub(:find_by_pixi_id) { @listing }
        do_update
      end

      it "should assign @listing" do
        Listing.stub(:find_by_pixi_id) { mock_listing(:update_attributes => false) }
        do_update
        assigns(:listing).should_not be_nil 
      end

      it "renders the edit form" do 
        Listing.stub(:find_by_pixi_id) { mock_listing(:update_attributes => false) }
        do_update
	      response.should render_template(:show)
      end
    end
  end

  describe 'GET invoiced' do
    before(:each) do
      @listings = stub_model(Listing)
      Listing.stub_chain(:invoiced, :paginate).and_return(@listings)
      controller.stub_chain(:load_data, :get_location).and_return(:success)
      do_get
    end

    def do_get
      xhr :get, :invoiced
    end

    it "renders the :invoiced view" do
      response.should render_template :invoiced
    end

    it "should assign @listings" do
      assigns(:listings).should_not be_nil
    end

    it "responds to JSON" do
      xhr :get, :invoiced, :format => 'json'
      expect(response).to be_success
    end
  end
end
