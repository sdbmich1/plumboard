require 'login_user_spec'

describe SearchesController do
  include LoginTestUser

  def mock_listing(stubs={})
    (@mock_listing ||= mock_model(Listing, stubs).as_null_object).tap do |listing|
       allow(listing).to receive(stubs) unless stubs.empty?
    end
  end

  describe 'POST /locate', locate: true do
    before :each do
      log_in_test_user
      allow_message_expectations_on_nil
      @listings = stub_model(Listing)
      @sellers = stub_model(User)
      allow(Listing).to receive(:search).and_return( @listings )
      allow(@listings).to receive(:populate).and_return(@listings)
      allow(User).to receive(:get_sellers).and_return( @sellers )
      allow(controller).to receive_message_chain(:query, :page, :add_points, :get_location, :set_params, :search_options).and_return(:success)
    end

    def do_post
      xhr :post, :locate, locate: {loc: 1, cid: 1, url: '', search: 'test'}
    end

    it "should load the requested listing" do
      allow(Listing).to receive(:search).with('test').and_return(@listings)
      do_post
    end

    it "should assign @listings" do
      do_post
      expect(assigns(:listings)).to eq(@listings)
    end

    it "index action should render nothing" do
      do_post
      allow(controller).to receive(:render)
    end
  end

  describe 'GET /index', base: true do
    before :each do
      allow(controller).to receive_message_chain(:query, :page, :add_points, :get_location, :set_params, :search_options).and_return(:success)
    end

    it_behaves_like "a load data request", 'Listing', 'search', 'index', 'populate', true, 'listings'
  end
end
