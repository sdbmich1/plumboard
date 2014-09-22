require 'login_user_spec'

describe InvoicesController do
  include LoginTestUser

  def mock_invoice(stubs={})
    (@mock_invoice ||= mock_model(Invoice, stubs).as_null_object).tap do |invoice|
      invoice.stub(stubs) unless stubs.empty?
    end
  end

  def mock_listing(stubs={})
    (@mock_listing ||= mock_model(Listing, stubs).as_null_object).tap do |listing|
      listing.stub(stubs) unless stubs.empty?
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
    @invoice = stub_model(Invoice, :id=>1, buyer_id: 12, seller_id: 1, price: 50, pixi_id: 'abc', quantity: 1, comment: "Guitar for Sale")
  end

  describe 'GET index' do

    before :each do
      @invoices = stub_model(Invoice)
      Invoice.stub_chain(:all, :paginate).and_return( @invoices )
      controller.stub!(:current_user).and_return(@user)
      do_get
    end

    def do_get
      get :index
    end

    it "should assign @user" do
      assigns(:user).should_not be_nil 
    end

    it "should assign @invoices" do
      assigns(:invoices).should_not be_nil
    end

    it "renders the :index view" do
      response.should render_template :index
    end

    it "should show the requested invoices" do
      response.should be_success
    end

    it "responds to JSON" do
      @expected = @invoices.to_json
      get  :index, format: :json
      response.body.should == @expected
    end
  end

  describe 'GET sent' do

    before :each do
      @invoices = stub_model(Invoice)
      Invoice.stub!(:get_invoices).and_return( @invoices )
      @invoices.stub!(:paginate).and_return( @invoices )
      do_get
    end

    def do_get
      get :sent
    end

    it "should assign @invoices" do
      assigns(:invoices).should_not be_nil
    end

    it "renders the :sent view" do
      response.should render_template :sent
    end

    it "should show the requested invoices" do
      response.should be_success
    end

    it "responds to JSON" do
      @expected = { :invoices  => @invoices }.to_json
      get  :sent, format: :json
      response.body.should_not be_nil
    end
  end

  describe "GET 'new'" do

    before :each do
      controller.stub!(:current_user).and_return(@user)
      Invoice.stub!(:load_new).with(@user).and_return( @invoice )
    end

    def do_get
      get :new
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

  describe "GET 'new'" do

    before :each do
      controller.stub!(:current_user).and_return(@user)
      Invoice.stub!(:load_new).with(@user).and_return( @invoice )
      do_get
    end

    def do_get
      xhr :get, :new
    end

    it "should assign @invoice" do
      assigns(:invoice).should_not be_nil
    end

    it "should load nothing" do
      controller.stub!(:render)
    end
  end

  describe 'xhr GET received' do
    before :each do
      @invoices = mock("invoices")
      Invoice.stub!(:get_buyer_invoices).and_return( @invoices )
      @invoices.stub!(:paginate).and_return( @invoices )
      do_get
    end

    def do_get
      xhr :get, :received
    end

    it "should load nothing" do
      controller.stub!(:render)
    end

    it "should assign @invoices" do
      assigns(:invoices).should_not be_nil
    end

    it "should show the requested invoices" do
      response.should be_success
    end
  end

  describe 'xhr GET index' do
    before :each do
      @invoices = mock("invoices")
      Invoice.stub_chain(:all, :paginate).and_return( @invoices )
      controller.stub!(:current_user).and_return(@user)
      do_get
    end

    def do_get
      xhr :get, :index
    end

    it "should load nothing" do
      controller.stub!(:render)
    end

    it "should assign @invoices" do
      assigns(:invoices).should_not be_nil
    end

    it "should show the requested invoices" do
      response.should be_success
    end
  end

  describe 'GET show' do
    before :each do
      Invoice.stub!(:includes) { Invoice }
      Invoice.stub!(:find).and_return( @invoice )
      do_get
    end

    def do_get
      get :show, id: '1'
    end

    it "should load the requested invoice" do
      Invoice.should_receive(:find).with('1').and_return(@invoice)
      do_get
    end

    it "should assign @invoice" do
      assigns(:invoice).should_not be_nil
    end

    it "renders the :show view" do
      response.should render_template :show
    end

    it "should show the requested invoice" do
      response.should be_success
    end
  end

  describe 'xhr GET show' do
    before :each do
      Invoice.stub!(:includes) { Invoice }
      Invoice.stub!(:find).and_return( @invoice )
      do_get
    end

    def do_get
      xhr :get, :show, id: '1'
    end

    it "should load nothing" do
      controller.stub!(:render)
    end

    it "should load the requested invoice" do
      Invoice.should_receive(:find).with('1').and_return(@invoice)
      do_get
    end

    it "should assign @invoice" do
      assigns(:invoice).should_not be_nil
    end

    it "should show the requested invoices" do
      response.should be_success
    end
  end

  describe "xhr GET 'edit/:id'" do

    before :each do
      Invoice.stub!(:includes) { Invoice }
      Invoice.stub!(:find).and_return( @invoice )
    end

    def do_get
      xhr :get, :edit, id: '1'
    end

    it "should assign @invoice" do
      do_get
      assigns(:invoice).should_not be_nil 
    end

    it "should load nothing" do
      controller.stub!(:render)
    end

    it "should load the requested invoice" do
      do_get
      response.should be_success
    end
  end

  describe "GET 'edit/:id'" do

    before :each do
      Invoice.stub!(:includes) { Invoice }
      Invoice.stub!(:find).and_return( @invoice )
      do_get
    end

    def do_get
      get :edit, id: '1'
    end

    it "should assign @invoice" do
      assigns(:invoice).should_not be_nil 
    end

    it "renders the :edit view" do
      response.should render_template :edit
    end

    it "should load the requested invoice" do
      response.should be_success
    end
  end

  describe "PUT /:id" do
    before (:each) do
      controller.stub!(:set_params).and_return(:success)
      controller.stub!(:current_user).and_return(@user)
      Invoice.stub!(:includes) { Invoice }
      Invoice.stub!(:find).and_return( @invoice )
    end

    def do_update
      xhr :put, :update, :id => "1", :invoice => {'pixi_id'=>'test', 'comment' => 'test'}
    end

    context "with valid params" do
      before (:each) do
        @invoice.stub(:update_attributes).and_return(true)
      end

      it "should load the requested invoice" do
        Invoice.stub!(:find) { @invoice }
        do_update
      end

      it "should update the requested invoice" do
        Invoice.stub!(:find).with("1") { mock_invoice }
	mock_invoice.should_receive(:update_attributes).with({'pixi_id' => 'test', 'comment' => 'test'})
        do_update
      end

      it "should assign @invoice" do
        Invoice.stub!(:find) { mock_invoice(:update_attributes => true) }
        do_update
        assigns(:invoice).should_not be_nil 
      end

      it "responds to JSON" do
        @expected = { :invoice  => @invoice }.to_json
        put :update, :id => "1", :invoice => {'pixi_id'=>'test', 'comment' => 'test'}, format: :json
        response.body.should == @expected
      end
    end

    context "with invalid params" do
    
      before (:each) do
        @invoice.stub(:update_attributes).and_return(false)
      end

      it "should load the requested invoice" do
        Invoice.stub!(:find) { @invoice }
        do_update
      end

      it "should assign @invoice" do
        Invoice.stub!(:find) { mock_invoice(:update_attributes => false) }
        do_update
        assigns(:invoice).should_not be_nil 
      end

      it "should not render anything" do 
        Invoice.stub!(:find) { mock_invoice(:update_attributes => false) }
        do_update
        controller.stub!(:render)
      end

      it "responds to JSON" do
        put :update, :id => "1", :invoice => {'pixi_id'=>'test', 'comment' => 'test'}, format: :json
	response.status.should eq(422)
      end
    end
  end

  describe "POST create" do

    def setup
      controller.stub!(:current_user).and_return(@user)
      @user.stub_chain(:invoices, :build).and_return(@invoice)
      controller.stub!(:set_params).and_return(:success)
    end

    def do_create
      setup
      xhr :post, :create, :invoice => { 'pixi_id'=>'test', 'comment'=>'test' }
    end
    
    context 'failure' do
      
      before :each do
        Invoice.stub!(:save).and_return(false)
      end

      it "assigns @invoice" do
        do_create
        assigns(:invoice).should_not be_nil 
      end

      it "renders the new template" do
        do_create
        controller.stub!(:render)
      end

      it "responds to JSON" do
        setup
        post :create, :invoice => { 'pixi_id'=>'test', 'comment'=>'test' }, format: :json
	response.status.should_not eq(0)
      end
    end

    context 'success' do

      before :each do
        Invoice.stub!(:save).and_return(true)
      end

      it "loads the requested invoice" do
        Invoice.stub(:new).with({'pixi_id'=>'test', 'comment'=>'test' }) { mock_invoice(:save => true) }
        do_create
      end

      it "assigns @invoice" do
        do_create
        assigns(:invoice).should_not be_nil 
      end

      it "redirects to the created invoice" do
        Invoice.stub(:new).with({'pixi_id'=>'test', 'comment'=>'test' }) { mock_invoice(:save => true) }
        do_create
      end

      it "changes invoice count" do
        lambda do
          do_create
          should change(Invoice, :count).by(1)
        end
      end

      it "responds to JSON" do
        setup
        post :create, :invoice => { 'pixi_id'=>'test', 'comment'=>'test' }, format: :json
        # expect(response).to be_success
	response.status.should_not eq(0)
      end
    end
  end

  describe "PUT /remove/:id" do
    before (:each) do
      Invoice.stub!(:find).and_return( @invoice )
    end

    def do_remove
      put :remove, :id => "1"
    end

    context "with valid params" do
      before (:each) do
        @invoice.stub(:update_attribute).and_return(true)
      end

      it "should load the requested invoice" do
        Invoice.stub(:find) { @invoice }
        do_remove
      end

      it "should update the requested invoice" do
        Invoice.stub(:find).with("1") { mock_invoice }
	mock_invoice.should_receive(:update_attribute).with({:status=>"removed"})
        do_remove
      end

      it "should assign @invoice" do
        Invoice.stub(:find) { mock_invoice(:update_attribute => true) }
        do_remove
        assigns(:invoice).should_not be_nil 
      end

      it "redirects to the updated invoice" do
        do_remove
        response.should be_redirect
      end
    end

    context "with invalid params" do
    
      before (:each) do
        @invoice.stub(:update_attribute).and_return(false)
      end

      it "should load the requested invoice" do
        Invoice.stub(:find) { @invoice }
        do_remove
      end

      it "should assign @invoice" do
        Invoice.stub(:find) { mock_invoice(:update_attribute => false) }
        do_remove
      end
    end
  end

  describe "DELETE 'destroy'" do

    before (:each) do
      Invoice.stub!(:includes) { Invoice }
      Invoice.stub!(:find).and_return(@invoice)
    end

    def do_delete
      xhr :delete, :destroy, :id => "37"
    end

    context 'success' do

      it "destroys the requested invoice" do
        Invoice.stub!(:find).with("37") { mock_invoice }
        mock_invoice.should_receive(:destroy)
        do_delete
      end

      it "redirects to the invoices list" do
        Invoice.stub!(:find) { mock_invoice }
        do_delete
        response.should_not be_redirect
      end

      it "should decrement the Invoice count" do
        lambda do
          do_delete
          should change(Invoice, :count).by(-1)
        end
      end
    end
  end
end
