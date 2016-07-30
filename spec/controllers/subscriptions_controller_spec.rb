require 'login_user_spec'

describe SubscriptionsController do
  include LoginTestUser

  def mock_subscription(stubs={})
    (@mock_subscription ||= mock_model(Subscription, stubs).as_null_object).tap do |subscription|
      allow(subscription).to receive_messages(stubs) unless stubs.empty?
    end
  end

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      allow(user).to receive_messages(stubs) unless stubs.empty?
    end
  end

  before :each do
    log_in_test_user
    @user = mock_user
    @sub = stub_model(Subscription, user_id: 1, plan_id: 1, stripe_id: '9900000002', card_account_id: 1, status: 'active')
  end

  describe "GET new" do
    it_behaves_like "a load data request", 'Subscription', 'load_new', 'new', 'new', false, 'sub'
  end

  describe "POST create" do
    before :each do
      allow(Subscription).to receive(:new).and_return(@sub)
      allow(@sub).to receive(:add_subscription).and_return(@sub)
      allow(@sub).to receive(:add_card_account).and_return(@sub)
    end
    it_behaves_like 'a model create assignment', 'Subscription', 'add_subscription', 'create', 'save', true, 'sub'
    it_behaves_like 'a model create assignment', 'Subscription', 'add_subscription', 'create', 'save', false, 'sub'
  end

  describe "GET show" do
    it_behaves_like "a load data request", 'Subscription', 'find_by_id', 'show', 'show', false, 'sub'
  end

  describe "GET edit" do
    it_behaves_like "a load data request", 'Subscription', 'find_by_id', 'edit', 'edit', false, 'sub'
  end

  describe "PUT update" do
    before do
      allow(controller).to receive(:params).and_return({ id: '1', subscription: { plan_id: 1 } })
      allow(Plan).to receive(:find).and_return(stub_model(Plan))
    end

    it_behaves_like 'a model update assignment', 'Subscription', 'find_by_id', 'update', 'update_subscription', true, 'sub'
    it_behaves_like 'a model update assignment', 'Subscription', 'find_by_id', 'update', 'update_subscription', false, 'sub'
  end

  describe "DELETE delete" do
    it_behaves_like 'a model delete assignment', 'Subscription', 'find_by_id', 'destroy', 'cancel_subscription', true, 'sub'
    it_behaves_like 'a model delete assignment', 'Subscription', 'find_by_id', 'destroy', 'cancel_subscription', false, 'sub'
  end

  describe "GET index" do
    it_behaves_like "a load data request", 'Subscription', 'load_new', 'new', 'new', false, 'sub'
  end
end
