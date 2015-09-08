require 'login_user_spec'

describe ListingsController do
  include LoginTestUser

  before(:each) do
    log_in_test_user
    @user = mock_klass('User')
    @listing = stub_model(Listing, :id=>1, pixi_id: '1', site_id: 1, seller_id: 1, title: "Guitar", description: "Guitar for Sale")
  end

  def set_status
    allow_message_expectations_on_nil
    controller.instance_variable_set(:@status, 'active')
    @status.stub!(:to_sym).and_return(:active)
  end

  def set_index_data
    set_status
    Listing.any_instance.stub(:geocode) { [1,1] }
    Listing.any_instance.stub(:created_date).and_return(DateTime.current)
    controller.stub!(:get_location).and_return(:success)
  end

  def get_board_data
    @sellers = stub_model(User)
    User.stub!(:get_sellers).and_return(@sellers)
    controller.stub!(:load_data).and_return(:success)
  end

  def load_comments
    @comments = stub_model(Comment)
    @comments.stub!(:paginate).and_return(@comments)
    controller.stub!(:add_points).and_return(:success)
  end

  describe 'GET index', index: true do
    before(:each) do
      set_index_data
    end
    context 'load board' do
      [true, false].each do |xhr|
        it_behaves_like "a load data request", 'Listing', 'check_category_and_location', 'index', 'paginate', xhr, 'listings'
      end
    end
  end

  describe 'GET local', local: true do
    before(:each) do
      @category = stub_model Category
      Category.stub!(:find).and_return(@category)
      get_board_data
    end
    context 'load board' do
      ['local', 'category'].each do |rte|
        it_behaves_like "a load data request", 'Listing', 'load_board', rte, 'set_page', false, 'listings'
      end
    end
  end

  describe 'GET seller', seller: true do
    before :each do
      set_status
    end
    it_behaves_like "a load data request", 'Listing', 'get_by_status_and_seller', 'seller', 'paginate', true, 'listings'
  end

  describe 'GET show/:id', show: true do
    before :each do
      load_comments
    end
    [true, false].each do |status|
      it_behaves_like "a show method", 'Listing', 'find_pixi', 'show', status, true, 'listing'
    end
  end

  describe 'xhr GET pixi_price', show: true do
    it_behaves_like "a show method", 'Listing', 'find_pixi', 'pixi_price', true, true, 'listing'
  end

  describe "PUT /:id", update: true do
    context "success" do
      [['update', 'update_attributes'], ['repost', 'repost']].each do |rte|
        it_behaves_like 'a model update assignment', 'Listing', 'find_pixi', rte[0], rte[1], true, 'listing'
        it_behaves_like 'a redirected page', 'Listing', 'find_pixi', rte[0], rte[1], true
      end
    end

    context 'failure' do
      [['update', 'update_attributes'], ['repost', 'repost']].each do |rte|
        it_behaves_like 'a model update assignment', 'Listing', 'find_pixi', rte[0], rte[1], false, 'listing'
        it_behaves_like 'a failed update template', 'Listing', 'find_pixi', rte[0], 'show', false
      end
    end
  end

  describe 'GET seller_wanted', manage: true do
    context 'load list' do
      [['wanted_list', 'wanted'], ['wanted_list','seller_wanted'], ['invoiced', 'invoiced'], ['purchased', 'purchased']].each do |rte|
        it_behaves_like "a load data request", 'Listing', rte[0], rte[1], 'paginate', true, 'listings'
      end
    end
  end

  describe 'GET by url', url: true do
    context 'url' do
      ['biz', 'mbr', 'pub', 'edu', 'career'].each do |loop| 
        it_behaves_like "a load data request", 'Listing', 'get_by_url', loop, 'paginate', false, 'listings'
      end
    end
  end
end
