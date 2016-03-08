require 'login_user_spec'

describe SavedListingsController do
  include LoginTestUser

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  def mock_listing(stubs={})
    (@mock_listing ||= mock_model(SavedListing, stubs).as_null_object).tap do |listing|
      listing.stub(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
    @user = mock_user
  end

  describe 'GET index' do

    before :each do
      @listings = stub_model(Listing)
      allow(controller).to receive(:current_user).and_return(@user)
      allow(Listing).to receive(:saved_list).and_return( @listings )
      allow(@listings).to receive(:paginate).and_return(@listings)
      do_get
    end

    def do_get
      get :index
    end

    it "should assign @listings" do
      expect(assigns(:listings)).not_to be_nil
    end

    it "renders the :index view" do
      expect(response).to render_template :index
    end

    it "should show the requested listings" do
      expect(response).to be_success
    end

    it "responds to JSON" do
      get :index, :format => 'json'
      expect(response).to be_success
    end
  end

  describe "POST create" do
    before :each do
      @saved_listing = mock_model SavedListing
      allow(controller).to receive(:current_user).and_return(@user)
      @user.stub_chain(:saved_listings, :build).and_return(@saved_listing)
      allow(controller).to receive(:reload_data).and_return(true)
    end
    
    def do_create
      xhr :post, :create, 'pixi_id'=>'1', user_id: '1'
    end

    context 'failure' do
      
      before :each do
        allow(@saved_listing).to receive(:save).and_return(false)
      end

      it "should assign @saved_listing" do
        do_create
        expect(assigns(:saved_listing)).not_to be_nil 
      end

      it "should render nothing" do
        do_create
	allow(controller).to receive(:render)
      end

      it "responds to JSON" do
        post :create, pixi_id: '1', format: :json
	expect(response.status).not_to eq(0)
      end
    end

    context 'success' do

      before :each do
        allow(@saved_listing).to receive(:save).and_return(true)
      end

      it "should load the requested listing" do
        @user.stub_chain(:saved_listings, :build).with({pixi_id: '1'}) { mock_listing(:save => true) }
        do_create
      end

      it "should assign @saved_listing" do
        do_create
        expect(assigns(:saved_listing)).not_to be_nil 
      end

      it "should change saved_listing count" do
        lambda do
          do_create
          is_expected.to change(SavedListing, :count).by(1)
        end
      end
    end
  end

  describe "DELETE /:id" do
    before (:each) do
      @saved_listing = mock_model SavedListing
      allow(controller).to receive(:current_user).and_return(@user)
      @user.stub_chain(:saved_listings, :find_by_pixi_id).and_return(@saved_listing)
      allow(controller).to receive(:reload_data).and_return(true)
    end

    def do_delete
      xhr :delete, :destroy, :id => "37"
    end

    context "success" do
      before :each do
        allow(@saved_listing).to receive(:destroy).and_return(true)
      end

      it "should load the requested listing" do
        @user.stub_chain(:saved_listings, :find_by_pixi_id) { @saved_listing }
        do_delete
      end

      it "should delete the requested listing" do
        @user.stub_chain(:saved_listings, :find_by_pixi_id) { mock_listing }
	expect(mock_listing).to receive(:destroy).and_return(:success)
        do_delete
      end

      it "should assign @saved_listing" do
        @user.stub_chain(:saved_listings, :find_by_pixi_id) { mock_listing(:destroy => true) }
        do_delete
        expect(assigns(:saved_listing)).not_to be_nil 
      end

      it "should decrement the SavedListing count" do
	lambda do
	  do_delete
	  is_expected.to change(SavedListing, :count).by(-1)
	end
      end

      it "should render nothing" do
        do_delete
        allow(controller).to receive(:render)
      end
    end

    context 'failure' do
      before :each do
        allow(@saved_listing).to receive(:destroy).and_return(false) 
      end

      it "should assign saved_listing" do
        do_delete
        expect(assigns(:saved_listing)).not_to be_nil 
      end

      it "should render nothing" do
        do_delete
        allow(controller).to receive(:render)
      end
    end
  end
end
