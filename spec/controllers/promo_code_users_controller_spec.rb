require 'login_user_spec'

RSpec.describe PromoCodeUsersController, type: :controller do
  include LoginTestUser

  before(:each) do
    log_in_test_user
    @user = mock_user
    @promo = stub_model PromoCodeUser 
  end

  describe "POST seller", create: true do
    [true, false].each do |status|
      it_behaves_like 'a model create assignment', 'PromoCodeUser', 'save', 'create', 'create', status, 'promo'
    end
  end

  describe 'GET index', index: true do
    context 'load sites' do
      it_behaves_like "a load data request", 'PromoCodeUser', 'get_by_user', 'index', 'paginate', true, 'promo'
    end
  end

  describe "PUT update" do
    before :each do
      allow(PromoCodeUser).to receive(:save).and_return(@promo)
    end

    def do_update success
      put :update, :id => '1'
    end

    context "failure" do
      it "assigns @promo" do
        do_update(false)
        expect(assigns(:promo)).not_to be_nil
      end
    end

    context "success" do
      it "assigns @promo" do
        do_update(true)
        expect(assigns(:promo)).not_to be_nil 
      end

      it "renders template" do 
        do_update(true)
        expect(response).not_to render_template(:update)
      end

      it "changes PromoCodeUser count" do
        lambda do
          do_update(true)
          is_expected.not_to change(PromoCodeUser, :count)
        end
      end
    end
  end

end
