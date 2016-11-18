require 'spec_helper'

describe PagesController do
  # render_views

  before(:each) do
    @listing = stub_model(Listing, :id=>1, pixi_id: '1', site_id: 1, seller_id: 1, title: "Guitar for Sale", description: "Guitar for Sale")
    @site = stub_model(Site, :id=>1, status: "active", name: "SF Bay Area", site_type_code: "region")
  end

  def load_data method
    @home = double("PageFacade", params: {loc: 1, url: 'test'}, method.to_sym=> nil, region: nil, faqs: nil, loc_name: nil)
    allow(LocationManager).to receive(:get_region).and_return(@site)
    allow(PageFacade).to receive(method.to_sym).and_return(@home)
    @region, @loc_name = [@site.id, @site.name]
  end

  describe 'GET home' do
    before(:each) do
      load_data 'site'
      do_get
    end

    def do_get
      get :home
    end

    it "renders the :home view" do
      expect(response).to render_template :home
    end

    it "should render the correct layout" do
      expect(response).to render_template("layouts/pages")
    end
  end

  describe "GET 'help'" do
    before(:each) do
      load_data 'site'
      @faqs = double("faqs")
      allow(Faq).to receive_message_chain(:active).and_return(@faqs)
      do_get
    end

    def do_get
      get 'help'
    end

    it "renders the :help view" do
      expect(response).to render_template :help
    end

    it "should render the correct layout" do
      expect(response).to render_template("layouts/about")
    end
  end

  describe "GET 'privacy'" do
    it "should be successful" do
      get 'privacy'
      expect(response).to be_success
    end

    it "should render the correct layout" do
      get 'privacy'
      expect(response).to render_template("layouts/about")
    end
  end

  describe "GET 'terms'" do
    it "should be successful" do
      get 'terms'
      expect(response).to be_success
    end

    it "should render the correct layout" do
      get 'terms'
      expect(response).to render_template("layouts/about")
    end
  end

  describe "GET 'about'" do
    it "should be successful" do
      get 'about'
      expect(response).to be_success
    end

    it "should render the correct layout" do
      get 'about'
      expect(response).to render_template("layouts/about")
    end
  end

  describe "GET 'welcome'" do
    it "should be successful" do
      get 'welcome'
      expect(response).to be_success
    end

    it "should render the correct layout" do
      get 'welcome'
      expect(response).to render_template("layouts/about")
    end
  end

  describe 'xhr GET location_name' do
    before :each do
      load_data 'site'
      do_get
    end

    def do_get
      xhr :get, :location_name, loc_name: 'SF'
    end

    it "should load nothing" do
      allow(controller).to receive(:render)
    end

    it "should show the requested location_name" do
      expect(response).to be_success
    end

    it "responds to JSON" do
      get :location_name, :loc_name => 'SF', :format => :json
      expect(response).to be_success
    end
  end

  describe 'xhr GET location_id' do
    before :each do
      load_data 'site'
      allow(LocationManager).to receive(:get_loc_id).and_return(@loc_id)
      do_get
    end

    def do_get
      xhr :get, :location_id, loc_id: 'SF'
    end

    it "should load nothing" do
      allow(controller).to receive(:render)
    end

    it "should show the requested location_id" do
      expect(response).to be_success
    end

    it "responds to JSON" do
      get :location_id, :zip => '94109', :format => :json
      expect(response).to be_success
    end
  end

end
