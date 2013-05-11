require 'login_user_spec'

describe TransactionsController do
  include LoginTestUser

  def mock_transaction(stubs={})
    (@mock_transaction ||= mock_model(Transaction, stubs).as_null_object).tap do |transaction|
      transaction.stub(stubs) unless stubs.empty?
    end
  end

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
    @user = mock_user
    @transaction = stub_model(Transaction, :id=>1, first_name: "Test", last_name: "user", price: 5.00)
  end

  describe 'GET index' do
    before(:each) do
      @transactions = mock("transactions")
      Transaction.stub!(:all).and_return(@transactions)
    end

    def do_get
      get :index
    end

    it "renders the :index view" do
      do_get
      response.should render_template :index
    end

    it "should assign @transactions" do
      Transaction.should_receive(:all).and_return(@transactions)
      do_get 
      assigns(:transactions).should_not be_nil
    end
  end

  describe "GET 'new'" do

    before :each do
      @listing = stub_model(TempListing)
      TempListing.stub!(:find_by_pixi_id).and_return(@listing)
      controller.stub(:order) {['order', 'order']}
      controller.stub!(:current_user).and_return(@user)
      controller.stub!(:load_vars).and_return(:success)
      controller.stub!(:set_amt).and_return(:success)
      Transaction.stub!(:load_new).with(@user, @listing, @order).and_return( @transaction )
    end

    def do_get
      get :new
    end

    it "should assign @transaction" do
      do_get
      assigns(:transaction).should_not be_nil
    end

    it "should assign @listing" do
      do_get
      assigns(:listing).should_not be_nil
    end

    it "new action should render new template" do
      do_get
      response.should render_template(:new)
    end
  end

  describe 'GET show/:id' do
    before :each do
      Transaction.stub!(:find).and_return( @transaction )
    end

    def do_get
      get :show, :id => @transaction
    end

    it "should show the requested transaction" do
      do_get
      response.should be_success
    end

    it "should load the requested transaction" do
      Transaction.stub(:find).with(@transaction.id).and_return(@transaction)
      do_get
    end

    it "should assign @transaction" do
      do_get
      assigns(:transaction).should_not be_nil
    end

    it "show action should render show template" do
      do_get
      response.should render_template(:show)
    end
  end

  describe "POST create" do
    before :each do
      @listing = stub_model(TempListing)
      TempListing.stub!(:find_by_pixi_id).and_return(@listing)
    end
    
    context 'failure' do
      
      before :each do
        Transaction.stub!(:save_transaction).and_return(false)
      end

      def do_create
        post :create, id: '1'
      end

      it "should assign @transaction" do
        do_create
        assigns(:transaction).should_not be_nil 
      end

      it "should assign @listing" do
        do_create
        assigns(:listing).should_not be_nil 
      end

      it "create action should render new action" do
        do_create
        response.should render_template(:new)
      end
    end

    context 'success' do

      before :each do
        Transaction.stub!(:save_transaction).and_return(true)
      end

      def do_create
        post :create, id: '1', :transaction => { 'first_name'=>'test', 'description'=>'test' }, order: { "item_name" => 'New Pixi', "quantity" => 1, "price" => 5.00 }
      end

      it "should load the requested transaction" do
        Transaction.stub(:new).with({'first_name'=>'test', 'description'=>'test' }) { mock_transaction(:save_transaction => true) }
        do_create
      end

      it "should assign @transaction" do
        do_create
        assigns(:transaction).should_not be_nil 
      end

      it "should assign @listing" do
        do_create
        assigns(:listing).should_not be_nil 
      end

      it "should redirect to the created transaction" do
        Transaction.stub(:new).with({'first_name'=>'test', 'description'=>'test' }) { mock_transaction(:save_transaction => true) }
        do_create
        response.should be_redirect
      end

      it "should change transaction count" do
        lambda do
          do_create
          should change(Transaction, :count).by(1)
        end
      end
    end
  end
end
