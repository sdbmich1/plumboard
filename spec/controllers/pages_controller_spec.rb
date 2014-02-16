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

end
