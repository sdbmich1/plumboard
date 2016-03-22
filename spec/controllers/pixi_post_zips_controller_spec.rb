require 'login_user_spec'

describe PixiPostZipsController do
  include LoginTestUser

  def mock_zip(stubs={})
    (@mock_zip ||= mock_model(PixiPostZip, stubs).as_null_object).tap do |zip|
      allow(zip).to receive_messages(stubs) unless stubs.empty?
    end
  end

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      allow(user).to receive_messages(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
    @zip = stub_model(PixiPostZip, :id=>1, zip: 94108, city: "San Francisco", state: "CA", status: 'active')
  end

  describe 'GET check' do
    before(:each) do
      do_get
    end

    def do_get
      get :check
    end

    it "renders the :check view" do
      expect(response).to render_template :check
    end

    it "should render the correct layout" do
      expect(response).to render_template("layouts/pixi_post_zips")
    end
  end

  describe "GET /submit/:zip" do
    before (:each) do
      allow(PixiPostZip).to receive(:find_by_zip).and_return( @zip )
    end

    def do_submit
      get :submit, :zip => "94108"
    end

    context "success" do
      it "should load the requested zip" do
        allow(PixiPostZip).to receive(:find_by_zip) { @zip }
        do_submit
      end

      it "should assign @zip" do
        allow(PixiPostZip).to receive(:find_by_zip) { mock_zip }
        do_submit
        expect(assigns(:zip)).not_to be_nil 
      end

      it "redirects the page" do
        do_submit
	expect(response).to be_redirect
      end
    end

    context 'failure' do
      it "redirects the page" do
        do_submit
	expect(response).to be_redirect
      end
    end
  end

end
