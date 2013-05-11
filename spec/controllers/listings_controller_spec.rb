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
    @user = mock_user
    @listing = stub_model(Listing, :id=>1, site_id: 1, seller_id: 1, title: "Guitar for Sale", description: "Guitar for Sale")
  end

  describe 'GET index' do
    before(:each) do
      @listings = mock("listings")
      Listing.stub!(:active_page).and_return(@listings)
      controller.stub!(:load_data).and_return(:success)
      do_get
    end

    def do_get
      get :index
    end

    it "renders the :index view" do
      response.should render_template :index
    end

    it "should assign @listings" do
      assigns(:listings).should == @listings
    end

    it "should render the correct layout" do
      response.should render_template("layouts/listings")
    end
  end

  describe 'GET seller' do
    before :each do
      @listings = mock("listings")
      controller.stub!(:current_user).and_return(@user)
      @user.stub_chain(:pixis, :paginate).and_return( @listings )
      do_get
    end

    def do_get
      get :seller
    end

    it "renders the :seller view" do
      response.should render_template :seller
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
  end

  describe 'GET sold' do
    before :each do
      @listings = mock("listings")
      controller.stub!(:current_user).and_return(@user)
      @user.stub_chain(:sold_pixis, :paginate).and_return( @listings )
      do_get
    end

    def do_get
      xhr :get, :sold
    end

    it "renders the :sold view" do
      response.should render_template :sold
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
  end


  describe 'GET show/:id' do
    before :each do
      @photo = stub_model(Picture)
      @post = stub_model(Post)
      Listing.stub!(:find_by_pixi_id).and_return( @listing )
      Post.stub!(:load_new).with(@listing).and_return( @post )
      @listing.stub!(:pictures).and_return( @photo )
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
      Listing.stub(:find_by_pixi_id).with(@listing).and_return(@listing)
      do_get
    end

    it "should load the new post" do
      Post.stub(:load_new).with(@listing).and_return(@post)
      do_get
    end

    it "should assign @listing" do
      do_get
      assigns(:listing).should_not be_nil
    end

    it "should assign @post" do
      do_get
      assigns(:post).should_not be_nil
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
