require 'login_user_spec'

describe PixiWantsController do
  include LoginTestUser

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  def mock_want(stubs={})
    (@mock_want ||= mock_model(PixiWant, stubs).as_null_object).tap do |want|
      want.stub(stubs) unless stubs.empty?
    end
  end

  def mock_order
    { "cnt"=> 1, "item1"=> "Title", "id1"=> '1', "quantity1"=> 1,
      "title"=> "Title", "price1"=> 1.0, "promo_code"=> "" }
  end

  before(:each) do
    log_in_test_user
    @user = mock_user
  end

  describe "POST create" do
    before :each do
      @want = stub_model PixiWant
      controller.stub!(:current_user).and_return(@user)
      @user.stub_chain(:pixi_wants, :build).and_return(@want)
      controller.stub!(:reload_data).and_return(true)
      controller.stub!(:load_data).and_return(:success)
    end
    
    def do_create
      xhr :post, :create, id: '1'
    end

    context 'failure' do
      
      before :each do
        @want.stub!(:save).and_return(false)
      end

      it "should assign @want" do
        do_create
        assigns(:want).should_not be_nil 
      end

      it "should render nothing" do
        do_create
        controller.stub!(:render)
      end
    end

    context 'success' do

      before :each do
        @want.stub!(:save).and_return(true)
      end

      it "should load the requested want" do
        @user.stub_chain(:pixi_wants, :build) { mock_want(:save => true) }
        do_create
      end

      it "should assign @want" do
        do_create
        assigns(:want).should_not be_nil 
      end

      it "should change want count" do
        lambda do
          do_create
          should change(PixiWant, :count).by(1)
        end
      end

      it "responds to JSON" do
        post :create, pixi_want: { id: '1' }, format: :json
        response.body.should_not be_nil
      end
    end
  end

  describe "POST buy_now" do
    before :each do
      @want = stub_model PixiWant
      controller.stub!(:current_user).and_return(@user)
      @user.stub_chain(:pixi_wants, :build).and_return(@want)
      controller.stub!(:reload_data).and_return(true)
      Invoice.stub!(:process_invoice).and_return(:order)
      controller.stub!(:load_data).and_return(:success)
    end
    
    def do_buy_now
      xhr :post, :buy_now, id: "1", qty: "1", ftc: "P"
    end

    shared_examples "buy_now failure" do
      it "should assign want" do
        do_buy_now
        assigns(:want).should_not be_nil 
      end

      it "should render error" do
        do_buy_now
        controller.stub!(:render)
      end
    end

    context "want failure" do
      before :each do
        @want.stub!(:save).and_return(false)
      end
      it_behaves_like "buy_now failure"
    end

    context "order failure" do
      before :each do
        Invoice.stub!(:process_invoice).and_return(nil)
      end
      it_behaves_like "buy_now failure"
    end

    context "success" do
      before :each do
        @want.stub!(:save).and_return(true)
      end

      it "should redirect to new transaction" do
        @user.stub_chain(:pixi_wants, :build) { mock_want(:save => true) }
        Invoice.stub!(:process_invoice) { mock_order }
        do_buy_now
        response.should be_redirect
      end

      it "should assign @want and @order" do
        do_buy_now
        assigns(:want).should_not be_nil 
        assigns(:order).should_not be_nil 
      end

      it "should change want, invoice, and invoice detail count" do
        lambda do
          do_buy_now
          should change(PixiWant, :count).by(1)
          should change(Invoice, :count).by(1)
          should change(InvoiceDetail, :count).by(1)
        end
      end
    end
  end
end
