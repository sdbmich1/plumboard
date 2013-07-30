require 'spec_helper'

describe PagesController do
  render_views

  describe 'GET home' do
    before(:each) do
      @listings = mock("listings")
      @leaders = mock("users")
      Listing.stub!(:active).and_return(@listings)
      @listings.stub!(:paginate).and_return(@listings)
      PointManager.stub!(:daily_leaderboard).and_return(@leaders)
      controller.stub!(:load_data).and_return(:success)
      do_get
    end

    def do_get
      get :home
    end

    it "renders the :home view" do
      response.should render_template :home
    end

    it "should assign @listings" do
      assigns(:listings).should == @listings
    end

    it "should render the correct layout" do
      response.should render_template("layouts/pages")
    end
  end

  describe 'xhr GET index' do
    before(:each) do
      @listings = mock("listings")
      Listing.stub_chain(:active, :where).and_return(@listings)
      @listings.stub!(:empty?).and_return(:success)
      do_get
    end

    def do_get
      xhr :get, :index, after: '123'
    end

    it "renders the :index view" do
      response.should render_template :index
    end

    it "should assign @listings" do
      assigns(:listings).should == @listings
    end
  end

  describe "GET 'contact'" do
    it "should be successful" do
      get 'contact'
      response.should be_success
    end
  end

  describe "GET 'privacy'" do
    it "should be successful" do
      get 'privacy'
      response.should be_success
    end
  end

  describe "GET 'help'" do
    it "should be successful" do
      get 'help'
      response.should be_success
    end
  end

  describe "GET 'about'" do
    it "should be successful" do
      get 'about'
      response.should be_success
    end
  end

  describe "GET 'welcome'" do
    it "should be successful" do
      get 'welcome'
      response.should be_success
    end
  end

end
