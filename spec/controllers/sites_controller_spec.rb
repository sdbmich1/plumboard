require 'login_user_spec'

describe SitesController do
  include LoginTestUser

  before(:each) do
    log_in_test_user
    @user = mock_klass('User')
    @site = stub_model(Site, :id=>1, status: "active", name: "Berkeley", site_type_code: "school")
  end

  describe 'GET index', index: true do
    context 'load sites' do
      it_behaves_like "a load data request", 'Site', 'get_by_type', 'index', 'paginate', true, 'sites'
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

  describe 'GET /:id', show: true do
    [true, false].each do |status|
      it_behaves_like 'a show method', 'Site', 'find', 'show', status, true, 'site'
    end
  end

  describe "PUT /:id", update: true do
    [true, false].each do |status|
      it_behaves_like 'a model update assignment', 'Site', 'find', 'update', 'update_attributes', status, 'site'
    end
  end
end
