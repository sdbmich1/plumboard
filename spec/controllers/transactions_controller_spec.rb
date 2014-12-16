require 'login_user_spec'

describe TransactionsController do
  include LoginTestUser

  def mock_transaction(stubs={})
    (@mock_transaction ||= mock_model(Transaction, stubs).as_null_object).tap do |transaction|
      transaction.stub(stubs) unless stubs.empty?
    end
  end

  def mock_invoice(stubs={})
    (@mock_invoice ||= mock_model(Invoice, stubs).as_null_object).tap do |invoice|
      invoice.stub(stubs) unless stubs.empty?
    end
  end

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  def set_ability
    @abilities = Ability.new(@user)
    Ability.stub(:new).and_return(@abilities)
  end

  before(:each) do
    log_in_test_user
    @user = mock_user
    set_ability
    @transaction = stub_model(Transaction, first_name: "Test", last_name: "user", amt: 5.00, address: '123 Elm', city: 'LA', state: 'CA', 
      zip: '94108', home_phone: '4155551212', mobile_phone: '4155551212', email: 'test@test.com')
  end

  describe 'GET index' do
    before(:each) do
      @transactions = stub_model(Transaction)
      @transactions.updated_at = DateTime.current
      @invoice = stub_model(Invoice)
      @invoice.amount = 0
      @transactions.invoices.push(@invoice)
      Transaction.stub_chain(:get_by_date).and_return(@transactions)
      @transactions.stub!(:paginate).and_return(@transactions)
      controller.stub_chain(:load_date_range, :load_page).and_return(:success)
      do_get
    end

    def do_get
      get :index
    end

    it "renders the :index view" do
      response.should render_template :index
    end

    it "should assign @transactions" do
      assigns(:transactions).should_not be_nil
    end

    it "responds to JSON" do
      get :index, :format => 'json'
      expect(response).to be_success
    end 

    it "responds to CSV" do
      get :index, :format => 'csv'
      expect(response).to be_success
    end
  end

  describe 'xhr GET index' do
    before(:each) do
      @transactions = stub_model(Transaction)
      Transaction.stub!(:get_by_date).and_return(@transactions)
      @transactions.stub!(:paginate).and_return(@transactions)
    end

    def do_get
      xhr :get, :index
    end

    it "renders the :index view" do
      do_get
      response.should render_template :index
    end

    it "should assign @transactions" do
      Transaction.should_receive(:get_by_date).and_return(@transactions)
      do_get 
      assigns(:transactions).should_not be_nil
    end
  end

  describe "GET 'new'" do

    before :each do
      @listing = stub_model(TempListing)
      TempListing.stub!(:find_by_pixi_id).and_return(@listing)
      @invoice = stub_model(Invoice)
      controller.stub(:order) {['order', 'order']}
      controller.stub(:order) {['transaction_type', 'invoice']}
      controller.stub!(:current_user).and_return(@user)
      controller.stub_chain(:load_vars, :load_pixi, :set_amt).and_return(:success)
      Invoice.stub!(:find_invoice).with(@order).and_return(@invoice)
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

    it "should assign @invoice" do
      do_get
      assigns(:invoice).should eq(@invoice)
    end

    it "new action should render new template" do
      do_get
      response.should render_template(:new)
    end
  end

  describe 'GET show/:id' do
    before :each do
      Transaction.stub!(:find).and_return( @transaction )
      controller.stub!(:current_user).and_return(@user)
    end

    def do_get
      get :show, id: '1'
    end

    it "should show the requested transaction" do
      do_get
      response.should be_success
    end

    it "should load the requested transaction" do
      Transaction.stub!(:find).with('1').and_return(@transaction)
      # @user.stub_chain(:transactions, :find).with('1').and_return(@transaction)
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

    it "responds to JSON" do
      get  :show, :id => '1', format: :json
      response.status.should eq(200)
    end
  end

  describe "POST create" do
    before :each do
      @listing = stub_model(TempListing)
      TempListing.stub!(:find_by_pixi_id).and_return(@listing)
      Transaction.stub!(:new).and_return(@transaction)
    end

    def do_create
      post :create, id: '1', transaction: { 'first_name'=>'test', 'description'=>'test' }, order: { "item_name" => 'New Pixi', "quantity" => 1, 
	   "price" => 5.00 }
    end
    
    context 'failure' do
      before :each do
        Transaction.stub!(:save_transaction).and_return(false)
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
        response.should_not be_redirect
      end

      it "responds to JSON" do
        post :create, id: '1', transaction: { 'first_name'=>'test', 'description'=>'test' }, order: { "item_name" => 'New Pixi', "quantity" => 1, 
	   "price" => 5.00 }, :format=>:json
	response.status.should_not eq(0)
      end
    end

    context 'success' do

      before :each do
	@my_model = stub_model(Transaction,:save=>true)
        Transaction.stub!(:save_transaction).and_return(true)
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

      it "responds to JSON" do
        post :create, id: '1', transaction: { 'first_name'=>'test', 'description'=>'test' }, order: { "item_name" => 'New Pixi', "quantity" => 1, 
	   "price" => 5.00 }, format: :json
	response.status.should_not eq(0)
      end
    end
  end
end
