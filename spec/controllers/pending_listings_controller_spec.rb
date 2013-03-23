require 'login_user_spec'

describe PendingListingsController do
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
    @listing = stub_model(TempListing, :id=>1, site_id: 1, seller_id: 1, title: "Guitar for Sale", description: "Guitar for Sale")
  end

  describe 'GET index' do
    before(:each) do
      @listings = mock("listings")
      TempListing.stub!(:get_by_status).with('pending').and_return(@listings)
      @listings.stub!(:paginate).and_return(:success)
    end

    def do_get
      get :index
    end

    it "renders the :index view" do
      do_get
      response.should render_template :index
    end

    it "should assign @listings" do
      TempListing.should_receive(:get_by_status).with('pending').and_return(@listings)
      do_get 
      assigns(:listings).should_not be_nil
    end
  end

  describe 'GET show/:id' do
    before :each do
      @photo = stub_model(Picture)
      TempListing.stub!(:find_by_pixi_id).and_return( @listing )
      @listing.stub!(:pictures).and_return( @photo )
    end

    def do_get
      get :show, :id => @listing
    end

    it "should show the requested listing" do
      do_get
      response.should be_success
    end

    it "should load the requested listing" do
      TempListing.stub(:find_by_pixi_id).with(@listing.id).and_return(@listing)
      do_get
    end

    it "should assign @listing" do
      do_get
      assigns(:listing).should_not be_nil
    end

    it "should assign @photo" do
      do_get
      assigns(:listing).pictures.should_not be_nil
    end

    it "show action should render show template" do
      do_get
      response.should render_template(:show)
    end
  end

  describe "PUT /approve/:id" do
    before (:each) do
      TempListing.stub!(:find_by_pixi_id).and_return( @listing )
    end

    def do_approve
      put :approve, :id => "1"
    end

    context "success" do
      before :each do
        @listing.stub!(:approve_order).and_return(true)
      end

      it "should load the requested listing" do
        TempListing.stub(:find_by_pixi_id) { @listing }
        do_approve
      end

      it "should update the requested listing" do
        TempListing.stub(:find_by_pixi_id).with("1") { mock_listing }
	mock_listing.should_receive(:approve_order).and_return(:success)
        do_approve
      end

      it "should assign @listing" do
        TempListing.stub(:find_by_pixi_id) { mock_listing(:approve_order => true) }
        do_approve
        assigns(:listing).should_not be_nil 
      end

      it "redirects the page" do
        do_approve
	response.should be_redirect
      end
    end

    context 'failure' do
      before :each do
        @listing.stub!(:approve_order).and_return(false) 
      end

      it "should assign listing" do
        do_approve
        assigns(:listing).should_not be_nil 
      end

      it "should render show template" do
        do_approve
        response.should render_template(:show)
      end
    end
  end

  describe "PUT /deny/:id" do
    before (:each) do
      TempListing.stub!(:find_by_pixi_id).and_return( @listing )
    end

    def do_deny
      put :deny, :id => "1"
    end

    context "success" do
      before :each do
        @listing.stub!(:deny_order).and_return(true)
      end

      it "should load the requested listing" do
        TempListing.stub(:find_by_pixi_id) { @listing }
        do_deny
      end

      it "should update the requested listing" do
        TempListing.stub(:find_by_pixi_id).with("1") { mock_listing }
	mock_listing.should_receive(:deny_order).and_return(:success)
        do_deny
      end

      it "should assign @listing" do
        TempListing.stub(:find_by_pixi_id) { mock_listing(:deny_order => true) }
        do_deny
        assigns(:listing).should_not be_nil 
      end

      it "redirects the page" do
        do_deny
	response.should be_redirect
      end
    end

    context 'failure' do
      before :each do
        @listing.stub!(:deny_order).and_return(false) 
      end

      it "should assign listing" do
        do_deny
        assigns(:listing).should_not be_nil 
      end

      it "should render show template" do
        do_deny
        response.should render_template(:show)
      end
    end
  end
end
