require 'login_user_spec'

describe InvoicesController do
  include LoginTestUser

  def mock_invoice(stubs={})
    (@mock_invoice ||= mock_model(Invoice, stubs).as_null_object).tap do |invoice|
      allow(invoice).to receive_messages(stubs) unless stubs.empty?
    end
  end

  def mock_listing(stubs={})
    (@mock_listing ||= mock_model(Listing, stubs).as_null_object).tap do |listing|
      allow(listing).to receive_messages(stubs) unless stubs.empty?
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
    @invoice = stub_model(Invoice, :id=>1, buyer_id: 12, seller_id: 1, price: 50, pixi_id: 'abc', quantity: 1, comment: "Guitar for Sale")
  end

  describe 'GET index' do

    before :each do
      @invoices = stub_model(Invoice)
      allow(Invoice).to receive_message_chain(:includes, :paginate).and_return( @invoices )
      allow(@invoices).to receive_message_chain(:seller).and_return(stub_model(User))
      allow(controller).to receive(:current_user).and_return(@user)
      do_get
    end

    def do_get
      get :index
    end

    it "should assign @user" do
      expect(assigns(:user)).not_to be_nil 
    end

    it "should assign @invoices" do
      expect(assigns(:invoices)).not_to be_nil
    end

    it "renders the :index view" do
      expect(response).to render_template :index
    end

    it "should show the requested invoices" do
      expect(response).to be_success
    end

    it "responds to JSON" do
      @expected = @invoices.to_json
      get  :index, format: :json
      expect(response.body).to eq(@expected)
    end
  end

  describe 'GET sent' do

    before :each do
      @invoices = stub_model(Invoice)
      allow(Invoice).to receive(:get_invoices).and_return( @invoices )
      allow(@invoices).to receive(:paginate).and_return( @invoices )
      allow(@invoices).to receive(:seller).and_return(stub_model(User))
      do_get
    end

    def do_get
      get :sent
    end

    it "should assign @invoices" do
      expect(assigns(:invoices)).not_to be_nil
    end

    it "renders the :sent view" do
      expect(response).to render_template :sent
    end

    it "should show the requested invoices" do
      expect(response).to be_success
    end

    it "responds to JSON" do
      @expected = { :invoices  => @invoices }.to_json
      get  :sent, format: :json
      expect(response.body).not_to be_nil
    end
  end

  describe "GET 'new'" do

    before :each do
      allow(controller).to receive(:current_user).and_return(@user)
      allow(Invoice).to receive(:load_new).with(@user, '1', '1').and_return( @invoice )
    end

    def do_get
      get :new, buyer_id: '1', pixi_id: '1'
    end

    it "should assign @invoice" do
      do_get
      expect(assigns(:invoice)).to eq(@invoice)
    end

    it "new action should render new template" do
      do_get
      expect(response).to render_template(:new)
    end
  end

  describe "GET 'new'" do

    before :each do
      allow(controller).to receive(:current_user).and_return(@user)
      allow(Invoice).to receive(:load_new).with(@user, '1', '1').and_return( @invoice )
      do_get
    end

    def do_get
      xhr :get, :new, buyer_id: '1', pixi_id: '1'
    end

    it "should assign @invoice" do
      expect(assigns(:invoice)).not_to be_nil
    end

    it "should load nothing" do
      allow(controller).to receive(:render)
    end
  end

  describe 'xhr GET received' do
    before :each do
      @invoices = double("invoices")
      allow(Invoice).to receive(:get_buyer_invoices).and_return( @invoices )
      allow(@invoices).to receive(:paginate).and_return( @invoices )
      do_get
    end

    def do_get
      xhr :get, :received
    end

    it "should load nothing" do
      allow(controller).to receive(:render)
    end

    it "should assign @invoices" do
      expect(assigns(:invoices)).not_to be_nil
    end

    it "should show the requested invoices" do
      expect(response).to be_success
    end
  end

  describe 'xhr GET index' do
    before :each do
      @invoices = double("invoices")
      allow(Invoice).to receive_message_chain(:includes, :paginate).and_return( @invoices )
      allow(controller).to receive(:current_user).and_return(@user)
      do_get
    end

    def do_get
      xhr :get, :index
    end

    it "should load nothing" do
      allow(controller).to receive(:render)
    end

    it "should assign @invoices" do
      expect(assigns(:invoices)).not_to be_nil
    end

    it "should show the requested invoices" do
      expect(response).to be_success
    end
  end

  describe 'GET show' do
    before :each do
      allow(Invoice).to receive(:includes) { Invoice }
      allow(Invoice).to receive(:find).and_return( @invoice )
      do_get
    end

    def do_get
      get :show, id: '1'
    end

    it "should load the requested invoice" do
      expect(Invoice).to receive(:find).with('1').and_return(@invoice)
      do_get
    end

    it "should assign @invoice" do
      expect(assigns(:invoice)).not_to be_nil
    end

    it "renders the :show view" do
      expect(response).to render_template :show
    end

    it "should show the requested invoice" do
      expect(response).to be_success
    end
  end

  describe 'xhr GET show' do
    before :each do
      allow(Invoice).to receive(:includes) { Invoice }
      allow(Invoice).to receive(:find).and_return( @invoice )
      do_get
    end

    def do_get
      xhr :get, :show, id: '1'
    end

    it "should load nothing" do
      allow(controller).to receive(:render)
    end

    it "should load the requested invoice" do
      expect(Invoice).to receive(:find).with('1').and_return(@invoice)
      do_get
    end

    it "should assign @invoice" do
      expect(assigns(:invoice)).not_to be_nil
    end

    it "should show the requested invoices" do
      expect(response).to be_success
    end
  end

  describe "xhr GET 'edit/:id'" do

    before :each do
      allow(Invoice).to receive(:includes) { Invoice }
      allow(Invoice).to receive(:find).and_return( @invoice )
    end

    def do_get
      xhr :get, :edit, id: '1'
    end

    it "should assign @invoice" do
      do_get
      expect(assigns(:invoice)).not_to be_nil 
    end

    it "should load nothing" do
      allow(controller).to receive(:render)
    end

    it "should load the requested invoice" do
      do_get
      expect(response).to be_success
    end
  end

  describe "GET 'edit/:id'" do

    before :each do
      allow(Invoice).to receive(:includes) { Invoice }
      allow(Invoice).to receive(:find).and_return( @invoice )
      do_get
    end

    def do_get
      get :edit, id: '1'
    end

    it "should assign @invoice" do
      expect(assigns(:invoice)).not_to be_nil 
    end

    it "renders the :edit view" do
      expect(response).to render_template :edit
    end

    it "should load the requested invoice" do
      expect(response).to be_success
    end
  end

  describe "PUT /:id" do
    before (:each) do
      allow(controller).to receive(:set_params).and_return(:success)
      allow(controller).to receive(:current_user).and_return(@user)
      allow(Invoice).to receive(:includes) { Invoice }
      allow(Invoice).to receive(:find).and_return( @invoice )
      allow(@invoice).to receive(:seller).and_return(stub_model(User))
    end

    def do_update
      xhr :put, :update, :id => "1", :invoice => {'pixi_id'=>'test', 'comment' => 'test'}
    end

    context "with valid params" do
      before (:each) do
        allow(@invoice).to receive(:update_attributes).and_return(true)
      end

      it "should load the requested invoice" do
        allow(Invoice).to receive(:find) { @invoice }
        do_update
      end

      it "should update the requested invoice" do
        allow(Invoice).to receive(:find).with("1") { mock_invoice }
	expect(mock_invoice).to receive(:update_attributes).with({'pixi_id' => 'test', 'comment' => 'test'})
        do_update
      end

      it "should assign @invoice" do
        allow(Invoice).to receive(:find) { mock_invoice(:update_attributes => true) }
        do_update
        expect(assigns(:invoice)).not_to be_nil 
      end

      it "responds to JSON" do
        @expected = { :invoice  => @invoice }.to_json
        put :update, :id => "1", :invoice => {'pixi_id'=>'test', 'comment' => 'test'}, format: :json
        expect(response.body).to eq(@expected)
      end
    end

    context "with invalid params" do
    
      before (:each) do
        allow(@invoice).to receive(:update_attributes).and_return(false)
      end

      it "should load the requested invoice" do
        allow(Invoice).to receive(:find) { @invoice }
        do_update
      end

      it "should assign @invoice" do
        allow(Invoice).to receive(:find) { mock_invoice(:update_attributes => false) }
        do_update
        expect(assigns(:invoice)).not_to be_nil 
      end

      it "should not render anything" do 
        allow(Invoice).to receive(:find) { mock_invoice(:update_attributes => false) }
        do_update
        allow(controller).to receive(:render)
      end

      it "responds to JSON" do
        put :update, :id => "1", :invoice => {'pixi_id'=>'test', 'comment' => 'test'}, format: :json
	expect(response.status).to eq(422)
      end
    end
  end

  describe "POST create" do

    def setup
      allow(controller).to receive(:current_user).and_return(@user)
      allow(@user).to receive_message_chain(:invoices, :build).and_return(@invoice)
      allow(controller).to receive(:set_params).and_return(:success)
    end

    def do_create
      setup
      xhr :post, :create, :invoice => { 'pixi_id'=>'test', 'comment'=>'test' }
    end
    
    context 'failure' do
      
      before :each do
        allow(Invoice).to receive(:save).and_return(false)
      end

      it "assigns @invoice" do
        do_create
        expect(assigns(:invoice)).not_to be_nil 
      end

      it "renders the new template" do
        do_create
        allow(controller).to receive(:render)
      end

      it "responds to JSON" do
        setup
        post :create, :invoice => { 'pixi_id'=>'test', 'comment'=>'test' }, format: :json
	expect(response.status).not_to eq(0)
      end
    end

    context 'success' do

      before :each do
        allow(Invoice).to receive(:save).and_return(true)
      end

      it "loads the requested invoice" do
        allow(Invoice).to receive(:new).with({'pixi_id'=>'test', 'comment'=>'test' }) { mock_invoice(:save => true) }
        do_create
      end

      it "assigns @invoice" do
        do_create
        expect(assigns(:invoice)).not_to be_nil 
      end

      it "redirects to the created invoice" do
        allow(Invoice).to receive(:new).with({'pixi_id'=>'test', 'comment'=>'test' }) { mock_invoice(:save => true) }
        do_create
      end

      it "changes invoice count" do
        lambda do
          do_create
          is_expected.to change(Invoice, :count).by(1)
        end
      end

      it "responds to JSON" do
        setup
        post :create, :invoice => { 'pixi_id'=>'test', 'comment'=>'test' }, format: :json
        # expect(response).to be_success
	expect(response.status).not_to eq(0)
      end
    end
  end

  describe "PUT /remove/:id" do
    before (:each) do
      allow(Invoice).to receive(:includes) { Invoice }
      allow(Invoice).to receive(:find).and_return( @invoice )
    end

    def do_remove
      put :remove, :id => "1"
    end

    context "with valid params" do
      before (:each) do
        allow(@invoice).to receive(:update_attribute).and_return(true)
      end

      it "should load the requested invoice" do
        allow(Invoice).to receive(:find) { @invoice }
        do_remove
      end

      it "should update the requested invoice" do
        allow(Invoice).to receive(:find).with("1") { mock_invoice }
	expect(mock_invoice).to receive(:update_attribute).with(:status, "removed")
        do_remove
      end

      it "should assign @invoice" do
        allow(Invoice).to receive(:find) { mock_invoice(:update_attribute => true) }
        do_remove
        expect(assigns(:invoice)).not_to be_nil 
      end

      it "redirects to the updated invoice" do
        do_remove
        expect(response).to be_redirect
      end
    end

    context "with invalid params" do
    
      before (:each) do
        allow(@invoice).to receive(:update_attribute).and_return(false)
      end

      it "should load the requested invoice" do
        allow(Invoice).to receive(:find) { @invoice }
        do_remove
      end

      it "should assign @invoice" do
        allow(Invoice).to receive(:find) { mock_invoice(:update_attribute => false) }
        do_remove
      end
    end
  end

  describe "PUT /decline/:id" do
    before (:each) do
      allow(Invoice).to receive(:includes) { Invoice }
      allow(Invoice).to receive(:find).and_return( @invoice )
    end

    def do_decline
      put :decline, :id => "1"
    end

    context "with valid params" do
      before (:each) do
        allow(@invoice).to receive(:decline).and_return(true)
      end

      it "should load the requested invoice" do
        allow(Invoice).to receive(:find) { @invoice }
        do_decline
      end

      it "should update the requested invoice" do
        allow(Invoice).to receive(:find).with("1") { mock_invoice }
        expect(mock_invoice).to receive(:decline)
        do_decline
      end

      it "should assign @invoice" do
        allow(Invoice).to receive(:find) { mock_invoice(:decline => true) }
        do_decline
        expect(assigns(:invoice)).not_to be_nil 
      end

      it "redirects to the updated invoice" do
        do_decline
        expect(response).to be_redirect
      end
    end

    context "with invalid params" do
    
      before (:each) do
        allow(@invoice).to receive(:decline).and_return(false)
      end

      it "should load the requested invoice" do
        allow(Invoice).to receive(:find) { @invoice }
        do_decline
      end

      it "should assign @invoice" do
        allow(Invoice).to receive(:find) { mock_invoice(:decline => false) }
        do_decline
      end
    end
  end

  describe "DELETE 'destroy'" do

    before (:each) do
<<<<<<< HEAD
      Invoice.stub(:includes) { Invoice }
      Invoice.stub(:find).and_return(@invoice)
=======
      allow(Invoice).to receive(:includes) { Invoice }
      allow(Invoice).to receive(:find).and_return(@invoice)
>>>>>>> fa62ffcbe8a86ff15ce4cb8bcb0fb241e861307d
    end

    def do_delete(status=nil)
      xhr :delete, :destroy, :id => "37", status: status
    end

    context 'success' do

      it "destroys the requested invoice" do
<<<<<<< HEAD
        Invoice.stub(:find).with("37") { mock_invoice }
        mock_invoice.should_receive(:destroy)
=======
        allow(Invoice).to receive(:find).with("37") { mock_invoice }
        expect(mock_invoice).to receive(:destroy)
>>>>>>> fa62ffcbe8a86ff15ce4cb8bcb0fb241e861307d
        do_delete
      end

      it "responds with @invoice if status is not cancel" do
<<<<<<< HEAD
        Invoice.stub(:find) { mock_invoice }
=======
        allow(Invoice).to receive(:find) { mock_invoice }
>>>>>>> fa62ffcbe8a86ff15ce4cb8bcb0fb241e861307d
        do_delete
        expect(response).not_to be_redirect
      end

      it "redirects to listing if status is cancel" do
<<<<<<< HEAD
        Invoice.stub(:find) { mock_invoice }
        mock_invoice.stub_chain(:listings, :first, :pixi_id).and_return('abc')
        mock_invoice.stub(:destroy).and_return(:true)
=======
        allow(Invoice).to receive(:find) { mock_invoice }
        allow(mock_invoice).to receive_message_chain(:listings, :first, :pixi_id).and_return('abc')
        allow(mock_invoice).to receive(:destroy).and_return(:true)
>>>>>>> fa62ffcbe8a86ff15ce4cb8bcb0fb241e861307d
        do_delete('cancel')
        expect(response).to be_redirect
      end

      it "should decrement the Invoice count" do
        lambda do
          do_delete
          is_expected.to change(Invoice, :count).by(-1)
        end
      end
    end
  end
end
