require 'login_user_spec'

describe PostsController do
  include LoginTestUser

  def mock_listing(stubs={})
    (@mock_listing ||= mock_model(Listing, stubs).as_null_object).tap do |listing|
      listing.stub(stubs) unless stubs.empty?
    end
  end

  def mock_post(stubs={})
    (@mock_post ||= mock_model(Post, stubs).as_null_object).tap do |post|
      post.stub(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
  end

  describe "POST create" do
    before :each do
      @listing = mock_model Listing
      @post = mock_model Post
      Listing.stub!(:find_by_pixi_id).with('1').and_return(@listing)
    end
    
    def do_create
      xhr :post, :create, :post => { pixi_id: '1', 'content'=>'test' }
    end

    context 'failure' do
      
      before :each do
        Post.stub!(:save).and_return(false)
      end

      it "should assign @post" do
        do_create
        assigns(:post).should_not be_nil 
      end

      it "should render nothing" do
        do_create
	controller.stub!(:render)
      end
    end

    context 'success' do

      before :each do
        Post.stub!(:save).and_return(true)
        Post.stub!(:load_new).with(@listing).and_return(:success)
      end
       
      it "should load the requested listing" do
        Listing.stub(:find_by_pixi_id).with('1').and_return(:success)
        do_create
      end

      it "should assign @listing" do
        do_create
        assigns(:listing).should_not be_nil 
      end

      it "should load the requested post" do
        Post.stub(:new).with({'pixi_id'=>'1', 'content'=>'test' }) { mock_post(:save => true) }
        do_create
      end

      it "should assign @post" do
        do_create
        assigns(:post).should_not be_nil 
      end

      it "should change post count" do
        lambda do
          do_create
          should change(Post, :count).by(1)
        end
      end
    end
  end

end
