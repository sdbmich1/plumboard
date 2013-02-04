require 'spec_helper'

describe Transaction do
  before(:each) do
    @user = FactoryGirl.create(:user) 
    @transaction = FactoryGirl.build(:transaction, :user_id=>@user.id)
  end

  it "should have a user method" do
    @transaction.should respond_to(:user)
  end

  it "should have a listings method" do
    @transaction.should respond_to(:listings)
  end

  describe "when address is empty" do
    before { @transaction.address = "" }
    it { should_not be_valid }
  end

  describe "when address is too long" do
    before { @transaction.address = "@" * 51 }
    it { should_not be_valid }
  end

  describe "when city is invalid" do
    before { @transaction.city = "@@@@" }
    it { should_not be_valid }
  end

  describe "when city is too long" do
    before { @transaction.city = "@" * 51 }
    it { should_not be_valid }
  end

  describe "when city is empty" do
    before { @transaction.city = "" }
    it { should_not be_valid }
  end

  describe "when state is empty" do
    before { @transaction.state = "" }
    it { should_not be_valid }
  end

  describe "when zip is empty" do
    before { @transaction.zip = "" }
    it { should_not be_valid }
  end

  describe "when country is empty" do
    before { @transaction.country = "" }
    it { should_not be_valid }
  end

  describe "when home_phone is empty" do
    before { @transaction.home_phone = "" }
    it { should_not be_valid }
  end
 
  describe "when amt is empty" do
    before { @transaction.amt = "" }
    it { should_not be_valid }
  end
end
