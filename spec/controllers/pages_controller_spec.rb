require 'spec_helper'

describe PagesController do
  # render_views

  before(:each) do
    @listing = stub_model(Listing, :id=>1, pixi_id: '1', site_id: 1, seller_id: 1, title: "Guitar for Sale", description: "Guitar for Sale")
    @site = stub_model(Site, :id=>1, status: "active", name: "SF Bay Area", site_type_code: "region")
  end

  describe 'GET home' do
    before(:each) do
      @listings = stub_model(Listing)
      Listing.stub_chain(:active, :board_fields).and_return(@listings)
      @listings.stub_chain(:paginate).and_return(@listings)
      allow(controller).to receive(:load_data).and_return(:success)
      do_get
    end

    def do_get
      get :home
    end

    it "assigns @listings" do
      expect(assigns(:listings)).to eq(@listings)
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
      @faqs = double("faqs")
      Faq.stub_chain(:active).and_return(@faqs)
      do_get
    end

    def do_get
      get 'help'
    end

    it "renders the :help view" do
      expect(response).to render_template :help
    end

    it "should assign @faqs" do
      expect(assigns(:faqs)).to eq(@faqs)
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
      allow(LocationManager).to receive(:get_region).and_return(@site)
      @region, @loc_name = [@site.id, @site.name]
      do_get
    end

    def do_get
      xhr :get, :location_name, loc_name: 'SF'
    end

    it "should load nothing" do
      allow(controller).to receive(:render)
    end

    it "should assign @loc_name" do
      expect(assigns(:loc_name)).not_to be_nil
    end

    it "should assign @region" do
      expect(assigns(:region)).not_to be_nil 
    end

    it "should show the requested location_name" do
      expect(response).to be_success
    end

    it "responds to JSON" do
      get :location_name, :loc_name => 'SF', :format => :json
      expect(response).to be_success
    end
  end

end
