require 'login_user_spec'

describe FavoriteSellersController do
  include LoginTestUser

  before(:each) do
    log_in_test_user
    @user = mock_user
    @favorite = stub_model FavoriteSeller 
    set_ability
  end

  def set_ability
    @abilities = Ability.new(@user)
    Ability.stub(:new).and_return(@abilities)
  end

  describe "POST seller", create: true do
    [true, false].each do |status|
      it_behaves_like 'a model create assignment', 'FavoriteSeller', 'find_or_create_by_user_id_and_seller_id', 'create', 'create', status, 'favorite'
    end
  end

  describe 'GET index', index: true do
    context 'load sites' do
      it_behaves_like "a load data request", 'User', 'get_by_ftype', 'index', 'paginate', true, 'users'
    end
  end

  describe "PUT /:seller_id", seller: true do
    def setup success
      FavoriteSeller.stub!(:find_by_user_id_and_seller_id).and_return(@favorite)
      @favorite.stub!(:update_attribute).and_return(success)
    end

    def do_update success
      setup(success)
      put :update, :id => '1'
    end

    context "failure" do
      it "assigns @favorite" do
        do_update(false)
        assigns(:favorite).should_not be_nil
      end

      it "renders tempate" do
        do_update(false)
        response.should render_template(:update)
      end
    end

    context "success" do
      it "assigns @favorite" do
        do_update(true)
        assigns(:favorite).should_not be_nil 
      end

      it "renders template" do 
        do_update(true)
        response.should render_template(:update)
      end

      it "changes FavoriteSeller count" do
        lambda do
          do_create(true)
          should_not change(FavoriteSeller, :count)
        end
      end
    end
  end
end
