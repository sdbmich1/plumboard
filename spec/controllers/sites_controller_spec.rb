require 'login_user_spec'

describe SitesController do
  include LoginTestUser

  def mock_site(stubs={})
    (@mock_site ||= mock_model(Site, stubs).as_null_object).tap do |site|
      site.stub(stubs) unless stubs.empty?
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
    @site = stub_model(Site, :id=>1, status: "active", name: "Berkeley", site_type_code: "school")
  end

  describe 'GET index', index: true do
    context 'load sites' do
      [true, false].each do |xhr|
        it_behaves_like "a load data request", 'Site', 'get_by_type', 'index', 'paginate', xhr
      end
    end
  end

  describe 'GET /loc_name' do
    before :each do
      @sites = stub_model(Site)
      Site.stub!(:search).and_return( @sites )
      controller.stub_chain(:query).and_return(:success)
    end

    def do_get
      get :loc_name, search: 'test'
    end

    it "should load the requested site" do
      Site.stub(:search).with('test').and_return(@sites)
      do_get
    end

    it "should assign @sites" do
      do_get
      assigns(:sites).should == @sites
    end

    it "loc_name action should render nothing" do
      do_get
      controller.stub!(:render)
    end

    it "responds to JSON" do
      get :loc_name, search: 'test', format: :json
      expect(response).to be_success
    end
  end

end
