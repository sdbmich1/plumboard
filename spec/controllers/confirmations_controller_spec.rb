require 'spec_helper'

describe ConfirmationsController do

  before :each do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  def do_post
    post :create, :user => {'first_name'=>'test', 'last_name' => 'test', email: 'email@test.com'}
  end

  describe "POST create" do
    before :each do
      @user = stub_model(User)
      User.stub_chain(:where, :first).and_return(@user)
      @user.stub_chain(:confirmed_at, :nil?).and_return(true)
      @user.stub(:email).and_return('email@test.com')
      do_post
    end

    context 'success' do
      before :each do
        UserMailer.stub_chain(:delay, :confirmation_instructions).with(@user).and_return(:success)
      end

      it "should assign @user" do
	assigns(:user).should_not be_nil
      end

      it "renders home page" do
	response.should be_redirect
      end
    end

    context 'failure' do
      it "should render the next page" do
	response.should be_redirect
      end
    end

  end

end
