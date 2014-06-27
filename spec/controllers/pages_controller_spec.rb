require 'spec_helper'

describe PagesController do
  render_views

  describe 'GET home' do
    before(:each) do
      do_get
    end

    def do_get
      get :home
    end

    it "renders the :home view" do
      response.should render_template :home
    end

    it "should render the correct layout" do
      response.should render_template("layouts/pages")
    end
  end

  describe "GET 'help'" do
    before(:each) do
      @faqs = mock("faqs")
      Faq.stub_chain(:active).and_return(@faqs)
      do_get
    end

    def do_get
      get 'help'
    end

    it "renders the :help view" do
      response.should render_template :help
    end

    it "should assign @faqs" do
      assigns(:faqs).should == @faqs
    end

    it "should render the correct layout" do
      response.should render_template("layouts/about")
    end
  end

  describe "GET 'privacy'" do
    it "should be successful" do
      get 'privacy'
      response.should be_success
    end

    it "should render the correct layout" do
      get 'privacy'
      response.should render_template("layouts/about")
    end
  end

  describe "GET 'terms'" do
    it "should be successful" do
      get 'terms'
      response.should be_success
    end

    it "should render the correct layout" do
      get 'terms'
      response.should render_template("layouts/about")
    end
  end

  describe "GET 'about'" do
    it "should be successful" do
      get 'about'
      response.should be_success
    end

    it "should render the correct layout" do
      get 'about'
      response.should render_template("layouts/about")
    end
  end

  describe "GET 'welcome'" do
    it "should be successful" do
      get 'welcome'
      response.should be_success
    end

    it "should render the correct layout" do
      get 'welcome'
      response.should render_template("layouts/about")
    end
  end

  describe 'xhr GET location_name' do
    before :each do
      @loc, @loc_name = 1234, 'SF Bay Area'
      LocationManager.stub!(:get_region).and_return( [@loc, @loc_name] )
      do_get
    end

    def do_get
      xhr :get, :location_name, loc_name: 'SF'
    end

    it "should load nothing" do
      controller.stub!(:render)
    end

    it "should assign @loc_name" do
      assigns(:loc_name).should_not be_nil
    end

    it "should assign @loc" do
      assigns(:loc).should_not be_nil
    end

    it "should show the requested location_name" do
      response.should be_success
    end

    it "responds to JSON" do
      get :location_name, :loc_name => 'SF', :format => :json
      expect(response).to be_success
    end
  end

end
