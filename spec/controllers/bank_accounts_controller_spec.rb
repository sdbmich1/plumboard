require 'login_user_spec'

describe BankAccountsController do
  include LoginTestUser

  def mock_account(stubs={})
    (@mock_account ||= mock_model(BankAccount, stubs).as_null_object).tap do |account|
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
    @account = stub_model(BankAccount, user_id: 1, account_number: '9900000002', routing_number: '321174851', acct_name: 'Joe Blow Checking', 
      acct_type: 'Checking', status: 'active')
  end

  describe 'GET index', index: true do
    context 'load sites' do
      it_behaves_like "a load data request", 'BankAccount', 'acct_list', 'index', 'paginate', true, 'accounts'
    end
  end

  describe 'GET new', base: true do
    context 'load sites' do
      [true, false].each do |status|
        it_behaves_like "a load data request", 'BankAccount', 'new', 'new', 'new', status, 'account'
      end
    end
  end

  describe 'GET /:id', base: true do
    [true, false].each do |status|
      it_behaves_like 'a show method', 'BankAccount', 'find', 'show', true, true, 'account'
    end
  end

  describe "POST account", process: true do
    [true, false].each do |status|
      it_behaves_like 'a model create assignment', 'BankAccount', 'save_account', 'create', 'create', status, 'account'
    end
  end

  describe "DELETE account", process: true do
    [true, false].each do |status|
      it_behaves_like 'a model delete assignment', 'BankAccount', 'find', 'destroy', 'delete_account', status, 'account'
    end
    # it_behaves_like 'a delete redirected page', 'BankAccount', 'find', 'destroy', 'show', true
  end

end
