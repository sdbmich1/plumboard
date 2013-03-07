require 'spec_helper'

describe User do
  before(:each) do
    @user = FactoryGirl.create(:user)
  end

  subject { @user }

  describe "user methods" do
    it { should respond_to(:first_name) }
    it { should respond_to(:last_name) }
    it { should respond_to(:email) }
    it { should respond_to(:password) }
    it { should respond_to(:password_confirmation) }
    it { should respond_to(:birth_date) }
    it { should respond_to(:remember_me) }
    it { should respond_to(:gender) }
    it { should respond_to(:pictures) }

    it { should respond_to(:interests) }
    it { should respond_to(:contacts) }
    it { should respond_to(:user_interests) }
    it { should respond_to(:transactions) }
    it { should respond_to(:site_users) }
    it { should respond_to(:sites) } 
    it { should respond_to(:listings) } 
    it { should respond_to(:temp_listings) } 
  end

  describe "when first_name is empty" do
    before { @user.first_name = "" }
    it { should_not be_valid }
  end

  describe "when first_name is invalid" do
    before { @user.first_name = "@@@@" }
    it { should_not be_valid }
  end

  describe "when first_name is too long" do
    before { @user.first_name = "a" * 31 }
    it { should_not be_valid }
  end

  describe "when last_name is empty" do
    before { @user.last_name = "" }
    it { should_not be_valid }
  end

  describe "when last_name is invalid" do
    before { @user.last_name = "@@@" }
    it { should_not be_valid }
  end

  describe "when last_name is too long" do
    before { @user.last_name = "a" * 31 }
    it { should_not be_valid }
  end

  describe "when gender is empty" do
    before { @user.gender = "" }
    it { should_not be_valid }
  end

  describe "when birth_date is empty" do
    before { @user.birth_date = "" }
    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid } 
  end

  it "returns a user's full name as a string" do
    user = FactoryGirl.build(:user, first_name: "John", last_name: "Doe", email: "jdoe@test.com")
    user.name.should == "John Doe"
  end

  it "does not return a user's invalid full name as a string" do
    user = FactoryGirl.build(:user, first_name: "John", last_name: "Wilson", email: "jwilson@test.com")
    user.name.should_not == "John Smith"
  end

  describe 'contacts' do
    before(:each) do
      @sr = @user.contacts.create FactoryGirl.attributes_for(:contact)
    end

    it "has many contacts" do 
      @user.contacts.should include(@sr)
    end

    it "should destroy associated contacts" do
      @user.destroy
      [@sr].each do |s|
         Contact.find_by_id(s.id).should be_nil
       end
    end 
  end  

  describe 'pictures' do
    before(:each) do
      @sr = @user.pictures.create FactoryGirl.attributes_for(:picture)
    end

    it "has many pictures" do 
      @user.pictures.should include(@sr)
    end

    it "should destroy associated pictures" do
      @user.destroy
      [@sr].each do |s|
         Picture.find_by_id(s.id).should be_nil
       end
    end 
  end  
end
