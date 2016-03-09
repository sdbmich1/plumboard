require 'login_user_spec'

describe CardAccountsController do
  include LoginTestUser

  def mock_account(stubs={})
    (@mock_account ||= mock_model(CardAccount, stubs).as_null_object).tap do |account|
      allow(account).to receive_messages(stubs) unless stubs.empty?
    end
  end

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      allow(user).to receive_messages(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
    @user = mock_user
    @account = stub_model(CardAccount, user_id: 1, card_number: '4111111111111111', status: 'active', card_code: '123',
      expiration_month: 6, expiration_year: 2019, zip: '94108')
  end

  describe 'GET index', index: true do
    context 'load sites' do
      it_behaves_like "a load data request", 'CardAccount', 'card_list', 'index', 'paginate', true, 'accounts'
    end
  end

  describe 'GET new', new: true do
    context 'load sites' do
      it_behaves_like "a load data request", 'CardAccount', 'new', 'new', 'new', true, 'account'
    end
  end

  describe 'GET /:id', show: true do
    [true, false].each do |status|
      it_behaves_like 'a show method', 'CardAccount', 'find', 'show', true, true, 'account'
    end
  end

  describe "POST account", create: true do
    [true, false].each do |status|
      it_behaves_like 'a model create assignment', 'CardAccount', 'save_account', 'create', 'create', status, 'account'
    end
  end

  describe "DELETE account", delete: true do
    [true, false].each do |status|
      it_behaves_like 'a model delete assignment', 'CardAccount', 'find', 'destroy', 'delete_card', status, 'account'
    end
    it_behaves_like 'a delete redirected page', 'CardAccount', 'find', 'destroy', 'show', true
  end

end
