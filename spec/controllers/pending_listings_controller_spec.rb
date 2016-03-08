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
    # log_in_test_user
    log_in_admin_user
    @listing = stub_model(TempListing, :id=>1, site_id: 1, seller_id: 1, title: "Guitar for Sale", description: "Guitar for Sale")
  end

  def init_index
    @abilities = Ability.new(@user)
    allow(Ability).to receive(:new).and_return(@abilities)
    allow(@abilities).to receive(:can?).and_return(true)
    @listings = double("listings")
    allow(TempListing).to receive(:get_by_status).and_return(@listings)
    allow(@listings).to receive(:paginate).and_return(@listings)
    allow_any_instance_of(TempListing).to receive(:created_date).and_return(DateTime.current)
  end

  describe 'GET index' do
    before(:each) do
      init_index
    end

    def do_get
      get :index, status: 'pending'
    end

    it "renders the :index view" do
      do_get
      expect(response).to render_template :index
    end

    it "should assign @listings" do
      expect(TempListing).to receive(:get_by_status).and_return(@listings)
      do_get 
      expect(assigns(:listings)).not_to be_nil
    end

    it "responds to CSV" do
      get :index, :status => 'pending', :format => 'csv'
      expect(response).to be_success
    end
  end

  describe 'xhr GET index' do
    before(:each) do
      init_index
      do_get
    end

    def do_get
      xhr :get, :index, status: 'active'
    end

    it "renders the :index view" do
      expect(response).to render_template :index
    end

    it "should assign @listings" do
      expect(assigns(:listings)).not_to be_nil
    end
  end

  describe 'GET show/:id' do
    before :each do
      @photo = stub_model(Picture)
      allow(TempListing).to receive(:find_pixi).and_return( @listing )
      allow(@listing).to receive(:pictures).and_return( @photo )
    end

    def do_get
      get :show, :id => '1'
    end

    it "should show the requested listing" do
      do_get
      expect(response).to be_success
    end

    it "should load the requested listing" do
      allow(TempListing).to receive(:find_pixi).with('1').and_return(@listing)
      do_get
    end

    it "should assign @listing" do
      do_get
      expect(assigns(:listing)).not_to be_nil
    end

    it "should assign @photo" do
      do_get
      expect(assigns(:listing).pictures).not_to be_nil
    end

    it "show action should render show template" do
      do_get
      expect(response).to render_template(:show)
    end
  end

  describe "PUT /approve/:id" do
    before (:each) do
      allow(TempListing).to receive(:find_pixi).and_return( @listing )
    end

    def do_approve
      put :approve, :id => "1"
    end

    context "success" do
      before :each do
        allow(@listing).to receive(:approve_order).and_return(true)
      end

      it "should load the requested listing" do
        allow(TempListing).to receive(:find_pixi) { @listing }
        do_approve
      end

      it "should update the requested listing" do
        allow(TempListing).to receive(:find_pixi).with("1") { mock_listing }
	expect(mock_listing).to receive(:approve_order).and_return(:success)
        do_approve
      end

      it "should assign @listing" do
        allow(TempListing).to receive(:find_pixi) { mock_listing(:approve_order => true) }
        do_approve
        expect(assigns(:listing)).not_to be_nil 
      end

      it "redirects the page" do
        do_approve
	expect(response).to be_redirect
      end
    end

    context 'failure' do
      before :each do
        allow(@listing).to receive(:approve_order).and_return(false) 
      end

      it "should assign listing" do
        do_approve
        expect(assigns(:listing)).not_to be_nil 
      end

      it "should render show template" do
        do_approve
        expect(response).to render_template(:show)
      end
    end
  end

  describe "PUT /deny/:id" do
    before (:each) do
      allow(TempListing).to receive(:find_pixi).and_return( @listing )
    end

    def do_deny
      put :deny, :id => "1"
    end

    context "success" do
      before :each do
        allow(@listing).to receive(:deny_order).and_return(true)
      end

      it "should load the requested listing" do
        allow(TempListing).to receive(:find_pixi) { @listing }
        do_deny
      end

      it "should update the requested listing" do
        allow(TempListing).to receive(:find_pixi).with("1") { mock_listing }
	expect(mock_listing).to receive(:deny_order).and_return(:success)
        do_deny
      end

      it "should assign @listing" do
        allow(TempListing).to receive(:find_pixi) { mock_listing(:deny_order => true) }
        do_deny
        expect(assigns(:listing)).not_to be_nil 
      end

      it "redirects the page" do
        do_deny
	expect(response).to be_redirect
      end
    end

    context 'failure' do
      before :each do
        allow(@listing).to receive(:deny_order).and_return(false) 
      end

      it "should assign listing" do
        do_deny
        expect(assigns(:listing)).not_to be_nil 
      end

      it "should render show template" do
        do_deny
        expect(response).to render_template(:show)
      end
    end
  end
end
