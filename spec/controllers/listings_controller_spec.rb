require 'login_user_spec'

describe ListingsController do
  include LoginTestUser

  before(:each) do
    log_in_test_user
    @user = mock_klass('User')
    @listing = stub_model(Listing, :id=>1, pixi_id: '1', site_id: 1, seller_id: 1, title: "Guitar", description: "Guitar for Sale")
  end

  def load_data method
    @listing = double("ListingFacade", params: {loc: 1, url: 'test'}, method.to_sym=> nil, add_points: nil, comments: nil)
    allow(ListingFacade).to receive(:set_geo_data).and_return(@listing)
  end

  describe 'GET board data', local: true do
    context 'load board' do
      ['local', 'category'].each do |rte|
        ['board', 'nearby'].each do |method|
          it 'checks this' do
            load_data "#{method}_listings"
            get rte.to_sym, loc: 1
          end
        end
      end
    end
    context 'load by url' do
      ['biz', 'mbr', 'pub', 'edu', 'career', 'loc'].each do |rte| 
        it 'checks this' do
          load_data 'url_listings'
          get rte.to_sym, url: 'test'
        end
      end
    end
  end

  describe 'GET show/:id', show: true do
    it 'checks this' do
      load_data 'listing'
      get :show, id: 1
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

  describe 'GET lists', manage: true do
    context 'load list' do
      ['index', 'wanted', 'seller_wanted', 'invoiced', 'purchased', 'seller'].each do |rte|
        it 'checks this' do
          load_data "#{rte+'_listings'}"
          get rte.to_sym, loc: 1
        end
      end
    end
  end
end
