require 'spec_helper'

feature "Users" do
  subject { page }
  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    login_as(user, :scope => :user, :run_callbacks => false)
    user.confirm!
    @user = user
  end

  describe "GET /users" do
    it "should display listings" do 
      user = FactoryGirl.create(:user)
      visit users_path  
      page.should have_content("Joe Blow")
    end
  end
  
  describe "Review Users" do 
    before { visit user_path(user) }

    it "Views a user" do
      page.should have_selector('h2',    text: user.name) 
    end
  end
end
