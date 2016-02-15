require 'login_user_spec'

describe SearchesController do
  include LoginTestUser

  def mock_listing(stubs={})
    (@mock_listing ||= mock_model(Listing, stubs).as_null_object).tap do |listing|
       listing.stub(stubs) unless stubs.empty?
    end
  end

  describe 'POST /locate', locate: true do
    before :each do
      log_in_test_user
      allow_message_expectations_on_nil
      @listings = stub_model(Listing)
      @sellers = stub_model(User)
      Listing.stub!(:search).and_return( @listings )
      User.stub(:get_sellers).and_return( @sellers )
      controller.stub_chain(:query, :page, :add_points, :get_location, :set_params, :search_options).and_return(:success)
    end

    def do_post
      xhr :post, :locate, locate: {loc: 1, cid: 1, url: '', search: 'test'}
    end

    it "should load the requested listing" do
      Listing.stub(:search).with('test').and_return(@listings)
      do_post
    end

    it "should assign @listings" do
      do_post
      assigns(:listings).should == @listings
    end

    it "index action should render nothing" do
      do_post
      controller.stub!(:render)
    end
  end

  describe 'GET /index', base: true do
    it_behaves_like "a load data request", 'Listing', 'search', 'index', nil, true, 'listings'
  end
end
