require 'login_user_spec'

describe RatingsController do
  include LoginTestUser

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      allow(user).to receive(stubs) unless stubs.empty?
    end
  end

  def mock_rating(stubs={})
    (@mock_rating ||= mock_model(Rating, stubs).as_null_object).tap do |rating|
      allow(rating).to receive(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
    @user = mock_user
    @rating = stub_model(Rating, :id=>1, user_id: 1, seller_id: 10, pixi_id: '1', value: 2.5, comments: "Guitar for Sale")
  end

  describe "POST create" do
    before :each do
      @transaction = stub_model(Transaction)
      allow(Transaction).to receive(:find).with('1').and_return(@transaction)
      allow(controller).to receive(:current_user).and_return(@user)
      @user.stub_chain(:ratings, :build).and_return( @rating )
    end
    
    def do_create
      post :create, id: '1', :rating => { pixi_id: '1', 'comments'=>'test' }
    end

    context 'failure' do
      
      before :each do
        allow(@rating).to receive(:save).and_return(false)
      end

      it "should assign @rating" do
        do_create
        expect(assigns(:rating)).not_to be_nil 
      end

      it "should assign @transaction" do
        do_create
        expect(assigns(:transaction)).not_to be_nil 
      end

      it "should render nothing" do
        do_create
	allow(controller).to receive(:render)
      end
    end

    context 'success' do

      before :each do
        @rating = mock_model Rating
        @user.stub_chain(:ratings, :build).and_return( @rating )
        allow(@rating).to receive(:save).and_return(true)
      end

      after (:each) do
        @ratings = stub_model(Rating)
        allow(User).to receive(:find).with('1').and_return(@user)
        @user.stub_chain(:ratings, :build).and_return( @ratings )
      end
       
      it "should load the requested user" do
        allow(User).to receive(:find).with('1').and_return(@user)
        do_create
      end

      it "should assign @user" do
        do_create
        expect(assigns(:user)).not_to be_nil 
      end

      it "should assign @transaction" do
        do_create
        expect(assigns(:transaction)).not_to be_nil 
      end

      it "should load the requested rating" do
        @user.stub_chain(:ratings, :build).with({'pixi_id'=>'1', 'comments'=>'test' }) { mock_rating(:save => true) }
        do_create
      end

      it "should assign @rating" do
        do_create
        expect(assigns(:rating)).not_to be_nil 
      end

      it "should change rating count" do
        lambda do
          do_create
          is_expected.to change(Rating, :count).by(1)
        end
      end

      it "responds to JSON" do
        post :create, id: '1', :rating => { pixi_id: '1', 'comments'=>'test' }, format: :json
	expect(response.status).not_to eq(0)
      end
    end
  end
end
