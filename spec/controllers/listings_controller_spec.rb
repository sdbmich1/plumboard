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

  before(:each) do
    log_in_test_user
    @listing = stub_model(Listing, :id=>1, site_id: 1, seller_id: 1, title: "Guitar for Sale", description: "Guitar for Sale")
  end

  describe 'GET index' do
    before(:each) do
      @listings = mock("listings")
      Listing.stub!(:active).and_return(@listings)
    end

    def do_get
      get :index
    end

    it "renders the :index view" do
      do_get
      response.should render_template :index
    end

    it "should assign @listings" do
      Listing.should_receive(:active).and_return(@listings)
      do_get 
      assigns(:listings).should_not be_nil
    end
  end

  describe 'GET seller/:user_id' do
    before :each do
      @listings = mock("listings")
      @temp_listings = mock("temp_listings")
      @user = stub_model(User)
      User.stub!(:find).and_return(@user)
      @user.stub!(:listings).and_return( @listings )
      @user.stub!(:temp_listings).and_return( @temp_listings )
    end

    def do_get
      get :seller, user_id: '1'
    end

    it "renders the :seller view" do
      do_get
      response.should render_template :seller
    end

    it "should assign @user" do
      do_get 
      assigns(:user).should_not be_nil
    end

    it "should assign @listings" do
      do_get 
      assigns(:listings).should_not be_nil
    end

    it "should assign @temp_listings" do
      do_get 
      assigns(:temp_listings).should_not be_nil
    end

    it "should show the requested listings" do
      do_get
      response.should be_success
    end
  end

  describe 'GET show/:id' do
    before :each do
      @photo = stub_model(Picture)
      Listing.stub!(:find_by_pixi_id).and_return( @listing )
      @listing.stub!(:pictures).and_return( @photo )
    end

    def do_get
      get :show, :id => '1'
    end

    it "should show the requested listing" do
      do_get
      response.should be_success
    end

    it "should load the requested listing" do
      Listing.stub(:find_by_pixi_id).with(@listing).and_return(@listing)
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

end
