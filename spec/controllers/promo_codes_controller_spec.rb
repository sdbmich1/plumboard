require 'login_user_spec'

RSpec.describe PromoCodesController, type: :controller do
  include LoginTestUser

  def mock_promo(stubs={})
    (@mock_promo ||= mock_model(PromoCode, stubs).as_null_object).tap do |promo|
      allow(promo).to receive_messages(stubs) unless stubs.empty?
    end
  end

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      allow(user).to receive_messages(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
    allow_message_expectations_on_nil
    @user = mock_user
    @promo = stub_model(PromoCode, owner_id: 1, amountOff: 20, percentOff: nil, status: 'active')
  end

  describe 'GET index', index: true do
    before :each do
      allow(controller).to receive(:current_usr).and_return(@usr)
      allow(@usr).to receive(:id).and_return( :success )
    end
    context 'load promos' do
      it_behaves_like "a load data request", 'PromoCode', 'get_user_promos', 'index', 'paginate', true, 'promos'
    end
  end

  describe 'GET new', base: true do
    it_behaves_like "a load data request", 'PromoCode', 'new', 'new', 'new', true, 'promo'
  end

  describe 'GET /:id', base: true do
    [true, false].each do |status|
      it_behaves_like 'a show method', 'PromoCode', 'find', 'show', true, status, 'promo'
    end
  end

  describe 'GET /:id', edit: true do
    [true, false].each do |status|
      it_behaves_like 'a show method', 'PromoCode', 'find', 'edit', true, status, 'promo'
    end
  end

  describe "POST create" do
    before :each do
      allow(PromoCode).to receive(:new).and_return(@promo)
      allow(@promo).to receive(:save).and_return(@promo)
    end
    it_behaves_like 'a model create assignment', 'PromoCode', 'save', 'create', 'save', true, 'promo'
    it_behaves_like 'a model create assignment', 'PromoCode', 'save', 'create', 'save', false, 'promo'
  end

  describe "PUT update" do
    before do
      allow(PromoCode).to receive(:find).and_return(@promo)
      allow(@promo).to receive(:update_attributes).and_return(@promo)
    end

    it_behaves_like 'a model update assignment', 'PromoCode', 'find', 'update', 'update_attributes', true, 'promo'
    it_behaves_like 'a model update assignment', 'PromoCode', 'find', 'update', 'update_attributes', false, 'promo'
  end

  describe "DELETE delete" do
    before do
      allow(PromoCode).to receive(:find).and_return(@promo)
      allow(@promo).to receive(:destroy).and_return(@promo)
    end

    it_behaves_like 'a model delete assignment', 'PromoCode', 'find', 'destroy', 'destroy', true, 'promo'
    it_behaves_like 'a model delete assignment', 'PromoCode', 'find', 'destroy', 'destroy', false, 'promo'
  end

end
