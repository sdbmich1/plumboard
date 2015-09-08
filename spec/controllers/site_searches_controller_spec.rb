require 'login_user_spec'

describe SiteSearchesController do
  include LoginTestUser

  before(:each) do
    log_in_test_user
  end

  describe 'GET /index' do
    context 'load sites' do
      it_behaves_like 'searches controller index', 'Site', 'sites'
    end
  end
end
