require 'login_user_spec'

describe SearchesController do
  include LoginTestUser

  def mock_listing(stubs={})
    (@mock_listing ||= mock_model(Listing, stubs).as_null_object).tap do |listing|
       listing.stub(stubs) unless stubs.empty?
    end
  end

  before :each do
    log_in_test_user
    allow_message_expectations_on_nil
    @listings = mock("listings")
    Listing.stub!(:search).and_return( @listings )
    controller.stub!(:current_user).and_return(@user)
    @user.stub_chain(:user_pixi_points, :create).and_return(:success)
    controller.stub_chain(:query, :page, :add_points, :get_location, :search_options).and_return(:success)
  end

  describe 'GET /index' do
    def do_get
      xhr :get, :index, search: 'test'
    end

    it "should load the requested listing" do
      Listing.stub(:search).with('test').and_return(@listings)
      do_get
    end

    it "should assign @listings" do
      do_get
      assigns(:listings).should == @listings
    end

    it "index action should render nothing" do
      do_get
      controller.stub!(:render)
    end
  end
end
