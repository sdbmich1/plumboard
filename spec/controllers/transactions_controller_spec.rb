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
      @user = stub_model(User)
      User.stub!(:find).and_return(@user)
      Transaction.stub!(:load_new).with(@user).and_return( @transaction )
      controller.stub!(:load_vars).and_return(:success)
    end

    def do_get
      xhr :get, :new, user_id: '3' 
    end

    it "should assign @transaction" do
      do_get
      assigns(:transaction).should_not be_nil
    end

    it "new action should render new template" do
      do_get
      response.should render_template(:new)
    end
  end

  describe "GET 'build'" do

    before :each do
      @user = stub_model(User)
      User.stub!(:find).and_return(@user)
      @listing = stub_model(TempListing)
      TempListing.stub!(:find).and_return(@listing)
      Transaction.stub!(:load_new).with(@user).and_return( @transaction )
      controller.stub!(:load_vars).and_return(:success)
    end

    def do_get
      xhr :get, :build, user_id: '3', id: '1' #, order: { "item_name" => 'New Pixi', "quantity" => 1, "price" => 5.00 }
    end

    it "should assign @transaction" do
      do_get
      assigns(:transaction).should_not be_nil
    end

    it "should assign @listing" do
      do_get
      assigns(:listing).should_not be_nil
    end

    it "should assign @user" do
      do_get
      assigns(:user).should_not be_nil
    end

    it "build action should render build template" do
      do_get
      response.should render_template(:build)
    end
  end

  describe "POST create" do
    
    context 'failure' do
      
      before :each do
        @listing = stub_model(TempListing)
        TempListing.stub!(:find).and_return(@listing)
        Transaction.stub!(:save_transaction).and_return(false)
      end

      def do_create
        xhr :post, :create, id: '1'
      end

      it "should assign @transaction" do
        do_create
        assigns(:transaction).should_not be_nil 
      end

      it "should assign @listing" do
        do_create
        assigns(:listing).should_not be_nil 
      end

      it "create action should render nothing" do
        do_create
	controller.stub!(:render)
      end
    end

    context 'success' do

      before :each do
        @listing = stub_model(TempListing)
        TempListing.stub!(:find).and_return(@listing)
        Transaction.stub!(:save_transaction).and_return(true)
      end

      def do_create
        xhr :post, :create, id: '1', :transaction => { 'first_name'=>'test', 'description'=>'test' }, order: { "item_name" => 'New Pixi', "quantity" => 1, "price" => 5.00 }
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

      it "should not redirect to the created transaction" do
        Transaction.stub(:new).with({'first_name'=>'test', 'description'=>'test' }) { mock_transaction(:save_transaction => true) }
        do_create
        response.should_not be_redirect
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
