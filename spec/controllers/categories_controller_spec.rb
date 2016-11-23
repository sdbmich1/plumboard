require 'login_user_spec'

describe CategoriesController do
  include LoginTestUser

  def mock_category(stubs={})
    (@mock_category ||= mock_model(Category, stubs).as_null_object).tap do |category|
      allow(category).to receive_messages(stubs) unless stubs.empty?
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
    @category = stub_model(Category, name: 'Computer', category_type_code: 'sales', status: 'active')
  end

  def set_admin
    @user.add_role(:admin)
    @abilities = Ability.new(@user)
    allow(Ability).to receive(:new).and_return(@abilities)
    allow(@abilities).to receive(:can?).and_return(true)
  end

  def load_categories atype='active'
    @categories = double("categories")
    allow(Category).to receive(atype.to_sym).and_return(@categories)
    allow(@categories).to receive(:paginate).and_return(@categories)
    allow(controller).to receive(:current_user).and_return(@user)
    allow(@user).to receive(:home_zip).and_return('94108')
    allow(controller).to receive_message_chain(:get_page, :load_data, :load_list).and_return(:success)
    do_get
  end

  describe 'GET manage' do
    before(:each) do
      set_admin
      load_categories
    end

    def do_get
      get :manage
    end

    it "renders the :manage view" do
      expect(response).to render_template :manage
    end

    it "should assign @categories" do
      expect(assigns(:categories)).to eq(@categories)
    end

    it "should render the correct layout" do
      expect(response).to render_template("layouts/categories")
    end
  end

  describe 'GET index' do
    before(:each) do
      load_categories
    end

    def do_get
      get :index
    end

    it "renders the :index view" do
      expect(response).to render_template :index
    end

    it "should assign @categories" do
      expect(assigns(:categories)).to eq(@categories)
    end

    it "should render the correct layout" do
      expect(response).to render_template("layouts/categories")
    end
  end

  describe 'xhr GET index' do
    before(:each) do
      load_categories
    end

    def do_get
      xhr :get, :index
    end

    it "renders the :index view" do
      expect(response).to render_template :index
    end

    it "should assign @categories" do
      expect(assigns(:categories)).to eq(@categories)
    end

    it "loads nothing" do
      allow(controller).to receive(:render)
    end
  end

  describe 'xhr GET inactive' do
    before(:each) do
      set_admin
      load_categories 'inactive'
    end

    def do_get
      xhr :get, :inactive
    end

    it "renders the :inactive view" do
      expect(response).to render_template :inactive
    end

    it "should assign @categories" do
      expect(assigns(:categories)).to eq(@categories)
    end

    it "loads nothing" do
      allow(controller).to receive(:render)
    end
  end

  describe "GET 'new'" do

    before :each do
      set_admin
      allow(Category).to receive(:new).and_return(@category)
      allow(@category).to receive_message_chain(:pictures, :build).and_return( @photo )
      do_get
    end

    def do_get
      xhr :get, :new
    end

    it "assigns @category" do
      expect(assigns(:category)).not_to be_nil
    end

    it "should assign @photo" do
      do_get
      expect(assigns(:category).pictures).not_to be_nil
    end

    it "loads nothing" do
      allow(controller).to receive(:render)
    end
  end

  describe "POST create" do
    before :each do
      set_admin
    end
    
    context 'failure' do
      
      before :each do
        allow(Category).to receive(:save).and_return(false)
      end

      def do_create
        xhr :post, :create
      end

      it "assigns @category" do
        do_create
        expect(assigns(:category)).not_to be_nil 
      end

      it "loads nothing" do
        do_create
        allow(controller).to receive(:render)
      end
    end

    context 'success' do

      before :each do
        allow(Category).to receive(:save).and_return(true)
      end

      def do_create
        xhr :post, :create, :category => { 'name'=>'test', 'category_type_code'=>'test' }
      end

      it "loads the requested category" do
        allow(Category).to receive(:new).with({'name'=>'test', 'category_type_code'=>'test' }) { mock_category(:save => true) }
        do_create
      end

      it "assigns @category" do
        do_create
        expect(assigns(:category)).not_to be_nil 
      end

      it "redirect to the categories page" do
        do_create
        expect(response).to be_success
      end

      it "changes category count" do
        lambda do
          do_create
          is_expected.to change(Category, :count).by(1)
        end
      end
    end
  end

  describe "GET 'edit/:id'" do

    before :each do
      set_admin
      allow(Category).to receive(:find).and_return( @category )
    end

    def do_get
      xhr :get, :edit, id: '1'
    end

    it "loads the requested category" do
      expect(Category).to receive(:find).with('1').and_return(@category)
      do_get
    end

    it "assigns @category" do
      do_get
      expect(assigns(:category)).not_to be_nil 
    end

    it "loads the requested category" do
      do_get
      expect(response).to be_success
    end
  end

  describe "PUT /:id" do
    before (:each) do
      set_admin
      allow(Category).to receive(:find).and_return( @category )
    end

    def do_update
      put :update, :id => "1", :category => {'name'=>'test', 'category_type' => 'test'}
    end

    context "with valid params" do
      before (:each) do
        allow(@category).to receive(:update_attributes).and_return(true)
      end

      it "loads the requested category" do
        allow(Category).to receive(:find) { @category }
        do_update
      end

      it "updates the requested category" do
        allow(Category).to receive(:find).with("1") { mock_category }
	expect(mock_category).to receive(:update_attributes).with({'name' => 'test', 'category_type' => 'test'})
        do_update
      end

      it "assigns @category" do
        allow(Category).to receive(:find) { mock_category(:update_attributes => true) }
        do_update
        expect(assigns(:category)).not_to be_nil 
      end

      it "redirect to the categories page" do
        do_update
        expect(response).to be_redirect
      end
    end

    context "with invalid params" do
    
      before (:each) do
        allow(@category).to receive(:update_attributes).and_return(false)
      end

      it "loads the requested category" do
        allow(Category).to receive(:find) { @category }
        do_update
      end

      it "assigns @category" do
        allow(Category).to receive(:find) { mock_category(:update_attributes => false) }
        do_update
        expect(assigns(:category)).not_to be_nil 
      end

      it "renders the edit form" do 
        allow(Category).to receive(:find) { mock_category(:update_attributes => false) }
        do_update
        allow(controller).to receive(:render)
      end
    end
  end

  describe 'xhr GET category_type' do
    before :each do
      @category = stub_model(Category)
      allow(Category).to receive_message_chain(:find).and_return( @category )
      allow(@category).to receive_message_chain(:pictures, :first, :photo, :url).and_return( :success )
      do_get
    end

    def do_get
      xhr :get, :category_type, id: '1'
    end

    it "should load nothing" do
      allow(controller).to receive(:render)
    end

    it "should assign @category" do
      expect(assigns(:category)).not_to be_nil
    end

    it "should show the requested category category_type" do
      expect(response).to be_success
    end

    it "responds to JSON" do
      get :category_type, :id => '1', :format => :json
      expect(response).to be_success
    end
  end

  describe 'xhr GET location' do
    before(:each) do
      load_categories
    end

    def do_get
      xhr :get, :location
    end

    it "renders the :location view" do
      expect(response).to render_template :location
    end

    it "should assign @categories" do
      expect(assigns(:categories)).to eq(@categories)
    end

    it "loads nothing" do
      allow(controller).to receive(:render)
    end
  end

end
