require 'spec_helper'

describe Users::OmniauthCallbacksController do

  before :each do
    request.env["devise.mapping"] = Devise.mappings[:user]
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
         provider: 'facebook', uid: "fb-12345", info: { name: "Bob Smith" }, extra: { raw_info: { first_name: 'Bob', last_name: 'Smith',
	 email: 'bob.smith@test.com', birthday: "01/03/1989", gender: 'male' } } })
  end

  def fb_hash(provider='facebook', uid='12345', email="john@doe.com", name='John Doe')
    env = { "provider" => provider, "uid" => uid, "info" => { "email" => email, "name" => name },
      extra: { raw_info: { first_name: 'Bob', last_name: 'Smith', email: 'bob.smith@test.com', birthday: "01/03/1989", gender: 'male' } }}
    env
  end

  def stub_env_for_omniauth(provider = "facebook", uid = "1234567", email = "bob@contoso.com", name = "John Doe")
    env = { "omniauth.auth" => fb_hash(provider, uid, email, name) }
    @controller.stub!(:env).and_return(env)
    env
  end

  describe ".create" do
    it "should redirect back to sign_up page with an error when omniauth.auth is missing" do
      @controller.stub!(:env).and_return({"some_other_key" => "some_other_value"})
      get :facebook
      response.should be_redirect
    end

    it "should redirect back to sign_up page with an error when provider is missing" do
      stub_env_for_omniauth(nil)
      get :facebook
      response.should be_redirect
    end

    it "should change user count" do
      lambda do
        get :facebook
        should change(User, :count).by(1)
      end
    end

    it "should not change user count" do
      FactoryGirl.create :pixi_user, email: 'bob.smith@test.com'

      lambda do
        get :facebook
        should change(User, :count).by(0)
      end
    end

    it "should redirect to pixi page when provider is provided" do
      stub_env_for_omniauth
      get :facebook
      flash[:notice].should match /Successfully authenticated from Facebook account/
      response.should be_redirect
    end
  end

  describe "passthru" do
    it "should render file" do
      get :passthru, use_route: "/users/auth/facebook"
      response.should render_template(:file => "#{Rails.root}/public/404.html")
    end
  end

  describe "setup" do
    before :each do
      request.env["omniauth.strategy"] = OmniAuth.config.add_mock(:facebook, {:options => { :display=>'page'}})
      get :setup, use_route: "/users/auth/facebook/setup"
    end

    it "should render text" do
      response.should render_template(:text => "Setup complete.")
    end

    it "assigns request env" do
      request.env['omniauth.strategy'].options[:display].should == "page"
    end
  end
end
