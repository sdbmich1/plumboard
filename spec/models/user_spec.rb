require 'spec_helper'

describe User do
  before(:each) do
    @user = FactoryGirl.create(:contact_user)
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
    it { should respond_to(:provider) }
    it { should respond_to(:uid) }
    it { should respond_to(:fb_user) }
    it { should respond_to(:pictures) }

    it { should respond_to(:interests) }
    it { should respond_to(:contacts) }
    it { should respond_to(:user_interests) }
    it { should respond_to(:transactions) }
    it { should respond_to(:site_users) }
    it { should respond_to(:sites) } 
    it { should respond_to(:listings) } 
    it { should respond_to(:temp_listings) } 
    it { should respond_to(:posts) } 
    it { should respond_to(:incoming_posts) } 
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
      @sr = @user.contacts.build FactoryGirl.attributes_for(:contact)
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

  describe 'temp_listings' do
    before(:each) do
      @sr = @user.temp_listings.create FactoryGirl.attributes_for(:temp_listing)
    end

    it "has many temp_listings" do 
      @user.temp_listings.should include(@sr)
    end

    it "should destroy associated temp_listings" do
      @user.destroy
      [@sr].each do |s|
         TempListing.find_by_id(s.id).should be_nil
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

  describe "must have pictures" do
    let(:user) { FactoryGirl.build :user }

    it "should not save w/o at least one picture" do
      picture = user.pictures.build
      user.save
      user.should_not be_valid
    end

    it "should save with at least one picture" do
      picture = user.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo.jpg")
      user.save
      user.should be_valid
    end
  end

  describe 'pixis' do
    it "should return pixis" do
      @user.temp_listings.create FactoryGirl.attributes_for(:temp_listing)
      @user.listings.create FactoryGirl.attributes_for(:listing)
      @user.pixis.should_not be_empty
    end

    it "should not return pixis" do
      usr = FactoryGirl.create :contact_user
      usr.pixis.should be_empty
    end
  end

  describe 'facebook' do
    let(:user) { FactoryGirl.build :user }
    let(:auth) { OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
               provider: 'facebook', uid: "fb-12345", info: { name: "Bob Smith", image: "http://graph.facebook.com/708798320/picture?type=square" }, 
	       extra: { raw_info: { first_name: 'Bob', last_name: 'Smith',
	                email: 'bob.smith@test.com', birthday: "01/03/1989", gender: 'male' } } }) }

    it 'should return a user' do
      User.find_for_facebook_oauth(auth).email.should == 'bob.smith@test.com'
    end

    it 'should return a picture' do
      User.picture_from_url(user, auth).should_not be_nil
    end
  end

  describe 'password' do
    let(:user) { FactoryGirl.build :user }

    it 'should valid password' do
      user.password_required?.should be_true  
    end

    it 'should confirm password' do
      user.confirmation_required?.should be_true  
    end

    it 'should not valid password' do
      user.provider = 'facebook'
      user.password_required?.should_not be_true  
    end

    it 'should not confirm password' do
      user.provider = 'facebook'
      user.confirmation_required?.should_not be_true  
    end
  end

  describe 'convert time' do
    it 'should return a date' do
      User.convert_date("01/13/1989").should == "13/01/1989".to_date
    end

    it 'should not return a date' do
      User.convert_date(nil).should_not == "13/01/1989".to_date
    end
  end
end
