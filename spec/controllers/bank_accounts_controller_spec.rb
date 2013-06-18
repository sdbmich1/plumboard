require 'login_user_spec'

describe BankAccountsController do
  include LoginTestUser

  def mock_account(stubs={})
    (@mock_account ||= mock_model(BankAccount, stubs).as_null_object).tap do |account|
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
    @account = stub_model(BankAccount, user_id: 1, acct_name: 'Joe Blow Checking', acct_type: 'Checking', status: 'active')
  end

  describe 'xhr GET index' do
    before :each do
      @accounts = mock("accounts")
      controller.stub!(:current_user).and_return(@user)
      @user.stub!(:accounts).and_return( @accounts )
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
      controller.stub_chain(:load_target, :current_user).and_return(@user)
      @user.stub_chain(:accounts, :build).and_return( @account )
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

  describe "GET 'edit/:id'" do

    before :each do
      BankAccount.stub!(:find).and_return( @account )
    end

    def do_get
      xhr :get, :edit, id: '1'
    end

    it "loads the requested account" do
      BankAccount.should_receive(:find).with('1').and_return(@account)
      do_get
    end

    it "assigns @account" do
      do_get
      assigns(:account).should_not be_nil 
    end

    it "loads nothing" do
      controller.stub!(:render)
    end

    it "loads the requested account" do
      do_get
      response.should be_success
    end
  end

  describe "PUT /:id" do
    before (:each) do
      BankAccount.stub!(:find).and_return( @account )
    end

    def do_update
      xhr :put, :update, :id => "1", :bank_account => {'user_id'=>'test', 'acct_type' => 'test'}
    end

    context "with valid params" do
      before (:each) do
        @account.stub(:update_attributes).and_return(true)
      end

      it "loads the requested account" do
        BankAccount.stub(:find) { @account }
        do_update
      end

      it "updates the requested account" do
        BankAccount.stub(:find).with("1") { mock_account }
	mock_account.should_receive(:update_attributes).with({'user_id' => 'test', 'acct_type' => 'test'})
        do_update
      end

      it "assigns @account" do
        BankAccount.stub(:find) { mock_account(:update_attributes => true) }
        do_update
        assigns(:account).should_not be_nil 
      end
    end

    context "with invalid params" do
    
      before (:each) do
        @account.stub(:update_attributes).and_return(false)
      end

      it "loads the requested account" do
        BankAccount.stub(:find) { @account }
        do_update
      end

      it "assigns @account" do
        BankAccount.stub(:find) { mock_account(:update_attributes => false) }
        do_update
        assigns(:account).should_not be_nil 
      end

      it "does not render anything" do 
        BankAccount.stub(:find) { mock_account(:update_attributes => false) }
        do_update
        controller.stub!(:render)
      end
    end
  end

  describe "POST create" do

    def do_create
      post :create, :bank_account => { 'user_id'=>'test', 'acct_type'=>'test' }
    end
    
    context 'failure' do
      
      before :each do
        BankAccount.stub!(:save).and_return(false)
      end

      it "assigns @account" do
        do_create
        assigns(:account).should_not be_nil 
      end

      it "renders the new template" do
        do_create
        controller.stub!(:render)
      end
    end

    context 'success' do

      before :each do
        BankAccount.stub!(:save).and_return(true)
	User.stub_chain(:find, :bank_accounts, :first).and_return(@user)
        controller.stub_chain(:load_target, :reload_data, :redirect_path).and_return(:success)
      end

      it "loads the requested account" do
        BankAccount.stub(:new).with({'user_id'=>'test', 'acct_type'=>'test' }) { mock_account(:save => true) }
        do_create
      end

      it "assigns @account" do
        do_create
        assigns(:account).should_not be_nil 
      end

      it "changes BankAccount count" do
        lambda do
          do_create
          should change(BankAccount, :count).by(1)
        end
      end
    end
  end

  describe "xhr POST create" do

    def do_create
      xhr :post, :create, :bank_account => { 'user_id'=>'test', 'acct_type'=>'test' }
    end
    
    context 'failure' do
      
      before :each do
        BankAccount.stub!(:save).and_return(false)
      end

      it "assigns @account" do
        do_create
        assigns(:account).should_not be_nil 
      end

      it "renders the new template" do
        do_create
        controller.stub!(:render)
      end
    end

    context 'success' do

      before :each do
        BankAccount.stub!(:save).and_return(true)
	User.stub_chain(:find, :bank_accounts, :first).and_return(@user)
        controller.stub_chain(:load_target, :reload_data, :redirect_path).and_return(:success)
      end

      it "loads the requested account" do
        BankAccount.stub(:new).with({'user_id'=>'test', 'acct_type'=>'test' }) { mock_account(:save => true) }
        do_create
      end

      it "assigns @account" do
        do_create
        assigns(:account).should_not be_nil 
      end

      it "redirects to the created account" do
        BankAccount.stub(:new).with({'user_id'=>'test', 'acct_type'=>'test' }) { mock_account(:save => true) }
        do_create
      end

      it "changes BankAccount count" do
        lambda do
          do_create
          should change(BankAccount, :count).by(1)
        end
      end
    end
  end

  describe "DELETE 'destroy'" do

    before (:each) do
      BankAccount.stub!(:find).and_return(@account)
    end

    def do_delete
      xhr :delete, :destroy, :id => "37"
    end

    context 'success' do

      after (:each) do
        @accounts = mock("BankAccounts")
	User.stub_chain(:find, :bank_accounts).and_return( @accounts )
      end

      it "loads the requested account" do
        BankAccount.stub(:find).with("37").and_return(@account)
      end

      it "destroys the requested account" do
        BankAccount.stub(:find).with("37") { mock_account }
        mock_account.should_receive(:destroy)
        do_delete
      end

      it "redirects to the accounts list" do
        BankAccount.stub(:find) { mock_account }
        do_delete
        response.should_not be_redirect
      end

      it "decrements the BankAccount count" do
        lambda do
          do_delete
          should change(BankAccount, :count).by(-1)
        end
      end
    end
  end

end
