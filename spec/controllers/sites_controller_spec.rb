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

  describe 'GET new', new: true do
    context 'load sites' do
      it_behaves_like "a load data request", 'Site', 'new', 'new', 'new', false, 'site'
    end
  end

  describe 'GET loc_name', loc: true do
    before :each do
      controller.stub_chain(:query).and_return(:success)
    end
    it_behaves_like "a load data request", 'Site', 'search', 'loc_name', nil, true, 'sites'
    it_behaves_like "a JSON request", 'Site', 'search', 'loc_name', nil, true, 'sites'
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

  describe "POST account", create: true do
    [true, false].each do |status|
      it_behaves_like 'a model create assignment', 'Site', 'save_site', 'create', 'create', status, 'site'
    end
  end
end
