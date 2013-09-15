require 'spec_helper'

describe Inquiry do
  before(:each) do
    @inquiry = FactoryGirl.build(:inquiry) 
  end
   
  subject { @inquiry } 

  it { should respond_to(:comments) }
  it { should respond_to(:user_id) }
  it { should respond_to(:first_name) }
  it { should respond_to(:last_name) }
  it { should respond_to(:email) }
  it { should respond_to(:inquiry_type) }
  it { should respond_to(:status) }
  it { should respond_to(:user) }

  describe "when comments is empty" do
    before { @inquiry.comments = "" }
    it { should_not be_valid }
  end

  describe "when comments is not empty" do
    it { should be_valid }
  end

  describe "when first_name is empty" do
    before { @inquiry.first_name = "" }
    it { should_not be_valid }
  end

  describe "when first_name is invalid" do
    before { @inquiry.first_name = "@@@@" }
    it { should_not be_valid }
  end

  describe "when first_name is too long" do
    before { @inquiry.first_name = "a" * 31 }
    it { should_not be_valid }
  end

  describe "when last_name is empty" do
    before { @inquiry.last_name = "" }
    it { should_not be_valid }
  end

  describe "when last_name is invalid" do
    before { @inquiry.last_name = "@@@" }
    it { should_not be_valid }
  end

  describe "when last_name is too long" do
    before { @inquiry.last_name = "a" * 31 }
    it { should_not be_valid }
  end

  describe "validations" do

    it "should accept valid work email addresses" do
      addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
      addresses.each do |address|
        @inquiry.email = address
        @inquiry.should be_valid
      end
    end

    it "should reject invalid email addresses" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
      addresses.each do |address|
        @inquiry.email = address
        @inquiry.should_not be_valid
      end
    end
  end

  describe "when comments is empty" do
    before { @inquiry.comments = "" }
    it { should_not be_valid }
  end

  describe "when comments is not empty" do
    it { should be_valid }
  end

  describe "when inquiry_type is empty" do
    before { @inquiry.inquiry_type = "" }
    it { should_not be_valid }
  end

  describe "when inquiry_type is not empty" do
    it { should be_valid }
  end

  describe "should include active inquirys" do
    it { Inquiry.active.should_not be_nil }
  end

  describe "should not include inactive inquirys" do
    inquiry = FactoryGirl.create(:inquiry, :status=>'inactive')
    it { Inquiry.active.should_not include (inquiry) } 
  end

end
