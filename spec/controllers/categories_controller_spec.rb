require 'login_user_spec'

describe CategoriesController do
  include LoginTestUser

  def mock_category(stubs={})
    (@mock_category ||= mock_model(Category, stubs).as_null_object).tap do |category|
      category.stub(stubs) unless stubs.empty?
    end
  end

  def mock_user(stubs={})
    (@mock_user ||= mock_model(Category, stubs).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
    @user = mock_user
    @category = stub_model(Category, name: 'Computer', category_type: 'sales', status: 'active')
  end

  def load_categories
    @categories = mock("categories")
    Category.stub!(:active).and_return(@categories)
    @categories.stub!(:paginate).and_return(@categories)
    controller.stub!(:get_page).and_return(:success)
  end

  describe 'GET manage' do
    before(:each) do
      load_categories
      do_get
    end

    def do_get
      get :manage
    end

    it "renders the :manage view" do
      response.should render_template :manage
    end

    it "should assign @categories" do
      assigns(:categories).should == @categories
    end

    it "should render the correct layout" do
      response.should render_template("layouts/listings")
    end
  end

  describe 'xhr GET index' do
    before(:each) do
      load_categories
      do_get
    end

    def do_get
      xhr :get, :index
    end

    it "renders the :index view" do
      response.should render_template :index
    end

    it "should assign @categories" do
      assigns(:categories).should == @categories
    end

    it "loads nothing" do
      controller.stub!(:render)
    end
  end

  describe 'xhr GET inactive' do
    before(:each) do
      @categories = mock("categories")
      Category.stub!(:inactive).and_return(@categories)
      @categories.stub!(:paginate).and_return(@categories)
      controller.stub!(:get_page).and_return(:success)
      do_get
    end

    def do_get
      xhr :get, :inactive
    end

    it "renders the :inactive view" do
      response.should render_template :inactive
    end

    it "should assign @categories" do
      assigns(:categories).should == @categories
    end

    it "loads nothing" do
      controller.stub!(:render)
    end
  end

  describe "GET 'new'" do

    before :each do
      Category.stub!(:new).and_return(@category)
      @category.stub_chain(:pictures, :build).and_return( @photo )
      do_get
    end

    def do_get
      xhr :get, :new
    end

    it "assigns @category" do
      assigns(:category).should_not be_nil
    end

    it "should assign @photo" do
      do_get
      assigns(:category).pictures.should_not be_nil
    end

    it "loads nothing" do
      controller.stub!(:render)
    end
  end

  describe "POST create" do
    
    context 'failure' do
      
      before :each do
        Category.stub!(:save).and_return(false)
      end

      def do_create
        xhr :post, :create
      end

      it "assigns @category" do
        do_create
        assigns(:category).should_not be_nil 
      end

      it "loads nothing" do
        do_create
        controller.stub!(:render)
      end
    end

    context 'success' do

      before :each do
        Category.stub!(:save).and_return(true)
        load_categories
      end

      def do_create
        xhr :post, :create, :category => { 'name'=>'test', 'category_type'=>'test' }
      end

      it "loads the requested category" do
        Category.stub(:new).with({'name'=>'test', 'category_type'=>'test' }) { mock_category(:save => true) }
        do_create
      end

      it "assigns @category" do
        do_create
        assigns(:category).should_not be_nil 
      end

      it "redirect to the categories page" do
        do_create
        response.should be_success
      end

      it "changes category count" do
        lambda do
          do_create
          should change(Category, :count).by(1)
        end
      end
    end
  end

  describe "GET 'edit/:id'" do

    before :each do
      Category.stub!(:find).and_return( @category )
    end

    def do_get
      xhr :get, :edit, id: '1'
    end

    it "loads the requested category" do
      Category.should_receive(:find).with('1').and_return(@category)
      do_get
    end

    it "assigns @category" do
      do_get
      assigns(:category).should_not be_nil 
    end

    it "loads the requested category" do
      do_get
      response.should be_success
    end
  end

  describe "PUT /:id" do
    before (:each) do
      Category.stub!(:find).and_return( @category )
    end

    def do_update
      xhr :put, :update, :id => "1", :category => {'name'=>'test', 'category_type' => 'test'}
    end

    context "with valid params" do
      before (:each) do
        @category.stub(:update_attributes).and_return(true)
        load_categories
      end

      it "loads the requested category" do
        Category.stub(:find) { @category }
        do_update
      end

      it "updates the requested category" do
        Category.stub(:find).with("1") { mock_category }
	mock_category.should_receive(:update_attributes).with({'name' => 'test', 'category_type' => 'test'})
        do_update
      end

      it "assigns @category" do
        Category.stub(:find) { mock_category(:update_attributes => true) }
        do_update
        assigns(:category).should_not be_nil 
      end

      it "redirect to the categories page" do
        do_update
        response.should be_success
      end
    end

    context "with invalid params" do
    
      before (:each) do
        @category.stub(:update_attributes).and_return(false)
      end

      it "loads the requested category" do
        Category.stub(:find) { @category }
        do_update
      end

      it "assigns @category" do
        Category.stub(:find) { mock_category(:update_attributes => false) }
        do_update
        assigns(:category).should_not be_nil 
      end

      it "renders the edit form" do 
        Category.stub(:find) { mock_category(:update_attributes => false) }
        do_update
        controller.stub!(:render)
      end
    end
  end


end
