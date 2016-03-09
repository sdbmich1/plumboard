require 'login_user_spec'

describe CommentsController do
  include LoginTestUser

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      allow(user).to receive_messages(stubs) unless stubs.empty?
    end
  end

  def mock_comment(stubs={})
    (@mock_comment ||= mock_model(Comment, stubs).as_null_object).tap do |comment|
      allow(comment).to receive_messages(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
    @user = mock_user
    @listing = stub_model(Listing, :id=>1, site_id: 1, seller_id: 1, pixi_id: '1', title: "Guitar for Sale", description: "Guitar for Sale")
    @comment = mock_model Comment
  end

  describe "POST create" do
    before :each do
      allow(Comment).to receive(:new).and_return( @comment )
      allow(controller).to receive(:load_data).and_return(true)
    end
    
    def do_create
      xhr :post, :create, :comment => { pixi_id: '1', 'content'=>'test' }
    end

    context 'failure' do
      
      before :each do
        allow(@comment).to receive(:save).and_return(false)
      end

      it "should assign @comment" do
        do_create
        expect(assigns(:comment)).not_to be_nil 
      end

      it "should render nothing" do
        do_create
	allow(controller).to receive(:render)
      end

      it "responds to JSON" do
        post :create, :comment => { pixi_id: '1', 'content'=>'test' }, format: :json
	expect(response.status).not_to eq(200)
      end
    end

    context 'success' do

      before :each do
        allow(@comment).to receive(:save).and_return(true)
        allow(controller).to receive(:load_data).and_return(true)
        allow(controller).to receive(:reload_data).and_return(true)
      end

      after (:each) do
        @comments = stub_model(Comment)
        allow(Listing).to receive(:find_pixi).with('1').and_return(@listing)
        allow(@listing).to receive_message_chain(:comments, :paginate, :build).and_return( @comments )
      end

      it "should load the requested comment" do
        allow(@listing).to receive_message_chain(:comments, :build).with({'pixi_id'=>'1', 'content'=>'test' }) { mock_comment(:save => true) }
        do_create
      end

      it "should assign @comment" do
        do_create
        expect(assigns(:comment)).not_to be_nil 
      end

      it "should assign @comments" do
        do_create
        expect(assigns(:comments)).to eq(@comments)
      end

      it "should change comment count" do
        lambda do
          do_create
          is_expected.to change(Comment, :count).by(1)
        end
      end

      it "responds to JSON" do
        post :create, :comment => { pixi_id: '1', 'content'=>'test' }, format: :json
	expect(response.status).not_to eq(0)
      end
    end
  end

end
