require 'login_user_spec'

describe SettingsController do
  include LoginTestUser

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      allow(user).to receive(stubs) unless stubs.empty?
    end
  end

  def mock_category(stubs={})
    (@mock_category ||= mock_model(Category, stubs).as_null_object).tap do |category|
      allow(user).to receive(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
    @user = mock_user
  end

  describe 'GET index', index: true do
    context 'load setting' do
      it_behaves_like "a load data request", 'User', 'find', 'index', nil, true, 'user'
      it_behaves_like "a load data request", 'User', 'find', 'index', nil, false, 'user'
    end
  end

  describe 'GET password', password: true do
    context 'load setting' do
      it_behaves_like "a load data request", 'User', 'find', 'password', 'password', true, 'user'
    end
  end

  describe 'GET contact', contact: true do
    context 'load setting' do
      it_behaves_like "a load data request", 'User', 'find', 'contact', 'contact', true, 'user'
    end
  end

  describe 'GET delivery', delivery: true do
    context 'load setting' do
      it_behaves_like "a load data request", 'User', 'find', 'delivery', 'delivery', true, 'user'
    end
  end
end
