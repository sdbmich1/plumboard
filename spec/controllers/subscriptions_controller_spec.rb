require 'login_user_spec'

describe SubscriptionsController do
  include LoginTestUser

  before :each do
    log_in_test_user
  end

  describe "GET new" do
    it_behaves_like "a load data request", 'Subscription', 'load_new', 'new', 'new', false, 'sub'
  end

  describe "POST create" do
    before do
      sub = mock_model(Subscription)
      allow(Subscription).to receive('new').and_return(sub)
      allow(sub).to receive('add_card_account').and_return(sub)
      allow(sub).to receive('add_subscription').and_return(true)
    end

    it_behaves_like 'a model create assignment', 'Subscription', 'new', 'create', 'save', true, 'sub'
    it_behaves_like 'a model create assignment', 'Subscription', 'new', 'create', 'save', false, 'sub'
  end

  describe "GET show" do
    it_behaves_like "a load data request", 'Subscription', 'find', 'show', 'show', false, 'sub'
  end

  describe "GET edit" do
    it_behaves_like "a load data request", 'Subscription', 'find', 'edit', 'edit', false, 'sub'
  end

  describe "PUT update" do
    before do
      allow(controller).to receive(:params).and_return({ id: '1', subscription: { plan_id: 1 } })
      allow(Plan).to receive(:find).and_return(stub_model(Plan))
    end

    it_behaves_like 'a model update assignment', 'Subscription', 'find', 'update', 'update_subscription', true, 'sub'
    it_behaves_like 'a model update assignment', 'Subscription', 'find', 'update', 'update_subscription', false, 'sub'
  end

  describe "DELETE delete" do
    it_behaves_like 'a model delete assignment', 'Subscription', 'find', 'destroy', 'cancel_subscription', true, 'sub'
    it_behaves_like 'a model delete assignment', 'Subscription', 'find', 'destroy', 'cancel_subscription', false, 'sub'
  end

  describe "GET index" do
    it_behaves_like "a load data request", 'Subscription', 'load_new', 'new', 'new', false, 'sub'
  end
end
