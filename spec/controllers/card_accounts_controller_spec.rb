require 'login_user_spec'

describe CardAccountsController do
  include LoginTestUser

  def mock_account(stubs={})
    (@mock_account ||= mock_model(CardAccount, stubs).as_null_object).tap do |account|
      account.stub(stubs) unless stubs.empty?
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
    @account = stub_model(CardAccount, user_id: 1, card_number: '4111111111111111', status: 'active', card_code: '123',
      expiration_month: 6, expiration_year: 2019, zip: '94108')
  end

  describe 'xhr GET index' do
    before :each do
      @accounts = mock("accounts")
      controller.stub!(:current_user).and_return(@user)
      @user.stub!(:card_accounts).and_return( @accounts )
      do_get
    end

    def do_get
      xhr :get, :index
    end

    it "loads nothing" do
      controller.stub!(:render)
    end

    it "assigns @user" do
      assigns(:user).should_not be_nil
    end

    it "assigns @accounts" do
      assigns(:accounts).should_not be_nil
    end

    it "shows the requested accounts" do
      response.should be_success
    end
  end

  describe "GET 'new'" do

    before :each do
      controller.stub_chain(:current_user).and_return(@user)
      @user.stub_chain(:card_accounts, :build).and_return( @account )
      do_get
    end

    def do_get
      get :new
    end

    it "assigns @account" do
      assigns(:account).should_not be_nil
    end

    it "loads new template" do
      response.should render_template(:new)
    end
  end

  describe "xhr GET 'new'" do

    before :each do
      controller.stub_chain(:current_user).and_return(@user)
      @user.stub_chain(:card_accounts, :build).and_return( @account )
      do_get
    end

    def do_get
      xhr :get, :new
    end

    it "assigns @account" do
      assigns(:account).should_not be_nil
    end

    it "loads nothing" do
      controller.stub!(:render)
    end
  end

  describe 'GET show/:id' do
    before :each do
      controller.stub!(:current_user).and_return(@user)
      @user.stub_chain(:card_accounts, :first).and_return( @account )
    end

    def do_get
      get :show, :id => '1'
    end

    it "should show the requested account" do
      do_get
      response.should be_success
    end

    it "should assign @account" do
      do_get
      assigns(:account).should_not be_nil
    end

    it "show action should render show template" do
      do_get
      response.should render_template(:show)
    end

    it "responds to JSON" do
      @expected = { 
        :account  => @account
      }.to_json

      get  :show, :id => '1', format: :json
      response.body.should == @expected
    end
  end

  describe "POST create" do

    def do_create
      post :create, :card_account => { 'user_id'=>'test', 'card_type'=>'test' }
    end
    
    context 'failure' do
      
      before :each do
        CardAccount.stub!(:save_account).and_return(false)
      end

      it "assigns @account" do
        do_create
        assigns(:account).should_not be_nil 
      end

      it "renders the new template" do
        do_create
        controller.stub!(:render)
      end

      it "responds to JSON" do
        post :create, :card_account => { 'user_id'=>'test', 'card_type'=>'test' }, :format=>:json
	response.status.should_not eq(0)
      end
    end

    context 'success' do

      before :each do
        CardAccount.any_instance.stub(:save_account).and_return({user_id: 1, card_number: '4111111111111111', status: 'active', card_code: '123',
            expiration_month: 6, expiration_year: 2019, zip: '94108'})
      end

      it "loads the requested account" do
        CardAccount.stub(:new).with({'user_id'=>'test', 'card_type'=>'test' }) { mock_account(:save => true) }
        do_create
      end

      it "assigns @account" do
        do_create
        assigns(:account).should_not be_nil 
      end

      it "changes CardAccount count" do
        lambda do
          do_create
          should change(CardAccount, :count).by(1)
        end
      end

      it "responds to JSON" do
        @expected = { :account  => @account }.to_json
        post :create, :card_account => { 'user_id'=>'test', 'card_type'=>'test' }, format: :json
        response.body.should_not be_nil
      end
    end
  end

  describe "xhr POST create" do

    def do_create
      xhr :post, :create, :card_account => { 'user_id'=>'test', 'card_type'=>'test' }
    end
    
    context 'failure' do
      
      before :each do
        CardAccount.stub!(:save_account).and_return(false)
      end

      it "assigns @account" do
        do_create
        assigns(:account).should_not be_nil 
      end

      it "renders nothing" do
        do_create
        controller.stub!(:render)
      end
    end

    context 'success' do

      before :each do
        CardAccount.any_instance.stub(:save_account).and_return({user_id: 1, card_number: '4111111111111111', status: 'active', card_code: '123',
            expiration_month: 6, expiration_year: 2019, zip: '94108'})
      end

      it "loads the requested account" do
        CardAccount.stub(:new).with({'user_id'=>'test', 'card_type'=>'test' }) { mock_account(:save => true) }
        do_create
      end

      it "assigns @account" do
        do_create
        assigns(:account).should_not be_nil 
      end

      it "redirects to the created account" do
        CardAccount.stub(:new).with({'user_id'=>'test', 'card_type'=>'test' }) { mock_account(:save => true) }
        do_create
      end

      it "changes CardAccount count" do
        lambda do
          do_create
          should change(CardAccount, :count).by(1)
        end
      end
    end
  end

  describe "DELETE 'destroy'" do

    before (:each) do
      CardAccount.stub!(:find).and_return(@account)
    end

    def do_delete
      xhr :delete, :destroy, :id => "37"
    end

    context 'failure' do
      before :each do
        @account.stub!(:delete_card).and_return(false) 
      end

      it "should assign account" do
        do_delete
        assigns(:account).should_not be_nil 
      end

      it "should render nothing" do
        do_delete
        controller.stub!(:render)
      end
    end

    context 'success' do

      it "loads the requested account" do
        CardAccount.stub(:find).with("37").and_return(@account)
      end

      it "destroys the requested account" do
        CardAccount.stub(:find).with("37") { mock_account }
        mock_account.should_receive(:delete_card)
        do_delete
      end

      it "redirects to the accounts list" do
        CardAccount.stub(:find) { mock_account }
        do_delete
        response.should be_redirect
      end

      it "decrements the CardAccount count" do
        lambda do
          do_delete
          should change(CardAccount, :count).by(-1)
        end
      end
    end
  end

end
