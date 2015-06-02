require 'login_user_spec'

describe FavoriteSellersController do
  include LoginTestUser

  before(:each) do
    log_in_test_user
    @user = mock_user
    @favorite = stub_model FavoriteSeller
  end

  describe "POST create" do
    def setup success
      controller.stub!(:current_user).and_return(@user)
      @user.stub!(:favorite_sellers).and_return(@favorite)
      @favorite.stub!(:find_or_create_by_seller_id).and_return(@favorite)
      @favorite.stub!(:update_attribute).and_return(success)
    end

    def do_create success
      setup(success)
      post :create, :seller_id => '2'
    end
    
    context 'failure' do
      it "assigns @favorite" do
        do_create(false)
        assigns(:favorite).should_not be_nil
      end

      it "renders template" do
        do_create(false)
        response.should render_template(:create)
      end
    end

    context 'success' do
      it "assigns @favorite" do
        do_create(true)
        assigns(:favorite).should_not be_nil 
      end

      it "renders template" do
        do_create(true)
        response.should render_template(:create)
      end

      it "changes FavoriteSeller count" do
        lambda do
          do_create(true)
          should change(FavoriteSeller, :count).by(1)
        end
      end
    end
  end

  describe "GET index" do
    before :each do
      @user = stub_model User
      controller.stub!(:current_user).and_return(@user)
      User.stub!(:get_by_ftype).and_return(@users)
      @users.stub!(:paginate).and_return(@users)
    end

    def do_get
      get :index
    end
    
    it "assigns @users" do
      do_get
      assigns(:users).should_not be_nil
    end

    it "renders :index template" do
      do_get
      response.should render_template(:index)
    end

    it "should render the correct layout" do
      do_get
      response.should render_template("layouts/application")
    end

    it "responds to JSON" do
      get :index, :format => 'json'
      expect(response).to be_success
    end
  end

  describe "PUT /:seller_id" do
    def setup success
      controller.stub!(:current_user).and_return(@user)
      @user.stub!(:favorite_sellers).and_return(@favorite)
      @favorite.stub!(:find_by_seller_id).and_return(@favorite)
      @favorite.stub!(:update_attribute).and_return(success)
    end

    def do_update success
      setup(success)
      put :update, :seller_id => '2'
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
