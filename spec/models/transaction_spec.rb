require 'spec_helper'

describe Transaction do
  before(:each) do
    @user = FactoryGirl.create(:user) 
    @transaction = FactoryGirl.build(:transaction, :user_id=>@user.id)
  end

  subject { @transaction }

  it { should respond_to(:first_name) }
  it { should respond_to(:last_name) }
  it { should respond_to(:address) }
  it { should respond_to(:address2) }
  it { should respond_to(:email) }
  it { should respond_to(:home_phone) }
  it { should respond_to(:work_phone) }
  it { should respond_to(:city) }
  it { should respond_to(:state) }
  it { should respond_to(:zip) }
  it { should respond_to(:payment_type) }
  it { should respond_to(:country) }
  it { should respond_to(:credit_card_no) }
  it { should respond_to(:description) }
  it { should respond_to(:amt) }
  it { should respond_to(:code) }
  it { should respond_to(:promo_code) }
  it { should respond_to(:user_id) }

  it { should respond_to(:user) }
  it { should respond_to(:listings) }

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

  describe "when amt is not a number" do
    before { @transaction.amt = "$500" }
    it { should_not be_valid }
  end
  
  describe "when amt is a number" do
    before { @transaction.amt = 50.00 }
    it { should be_valid }
  end
  
end
