require 'login_user_spec'

describe PromoCodeSearchesController do
  include LoginTestUser

  before(:each) do
    log_in_test_user
    allow_message_expectations_on_nil
  end

  describe 'GET /index', index: true do
    before :each do
      @promos = stub_model(PromoCode)
      allow(PromoCode).to receive(:search).and_return( @promos )
      allow(@promos).to receive(:populate).and_return(@promos)
      allow(controller).to receive_message_chain(:query, :page, :site, :load_search, :search_options).and_return(:success)
    end

    def do_action rte, method
      xhr rte.to_sym, method.to_sym, locate: {loc: 1, url: '', search_txt: 'test'}
    end

    [['get', 'index'], ['post', 'locate']].each do |rte, method|
      it "should load the requested promo" do
        allow(PromoCode).to receive(:search).with('test').and_return(@promos)
        do_action rte, method
      end

      it "should assign @promos" do
        do_action rte, method
        expect(assigns(:promos)).to eq(@promos)
      end

      it "index action should render nothing" do
        do_action rte, method
        allow(controller).to receive(:render)
      end
    end
  end
end
