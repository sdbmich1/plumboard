require 'login_user_spec'

describe PixiWantsController do
  include LoginTestUser

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      allow(user).to receive(stubs) unless stubs.empty?
    end
  end

  def mock_want(stubs={})
    (@mock_want ||= mock_model(PixiWant, stubs).as_null_object).tap do |want|
      allow(want).to receive(stubs) unless stubs.empty?
    end
  end

  def mock_order
    { "cnt"=> 1, "item1"=> "Title", "id1"=> '1', "quantity1"=> 1,
      "title"=> "Title", "price1"=> 1.0, "promo_code"=> "" }
  end

  before(:each) do
    log_in_test_user
    @user = mock_user
  end

  describe "POST account", process: true do
    it_behaves_like 'a model create assignment', 'PixiWant', 'save', 'create', 'create', true, 'want'
  end

  describe "POST buy_now", create: true do
    before :each do
      allow(Invoice).to receive(:process_invoice).and_return(:order)
    end
    [true, false].each do |status|
      it_behaves_like 'a model create assignment', 'PixiWant', 'save', 'buy_now', 'buy_now', status, 'want'
    end
  end
end
