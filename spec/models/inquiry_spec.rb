require 'spec_helper'

describe Inquiry do
  before(:each) do
    @user = FactoryGirl.create :pixi_user
    @inq_type = FactoryGirl.create :inquiry_type, contact_type: 'inquiry'
    @inquiry = @user.inquiries.build FactoryGirl.attributes_for(:inquiry, code: @inq_type.code) 
  end
   
  subject { @inquiry } 

  it { should respond_to(:comments) }
  it { should respond_to(:user_id) }
  it { should respond_to(:first_name) }
  it { should respond_to(:last_name) }
  it { should respond_to(:email) }
  it { should respond_to(:code) }
  it { should respond_to(:status) }
  it { should respond_to(:user) }
  it { should belong_to(:inquiry_type).with_foreign_key('code') }

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

  describe "when code is empty" do
    before { @inquiry.code = "" }
    it { should_not be_valid }
  end

  describe "when code is not empty" do
    it { should be_valid }
  end

  describe "should include active inquiries" do
    it { Inquiry.active.should_not be_nil }
  end

  describe "should not include inactive inquiries" do
    inquiry = FactoryGirl.create(:inquiry, :status=>'inactive')
    it { Inquiry.active.should_not include (inquiry) } 
  end

  describe ".list" do
    it { Inquiry.list.should be_empty }

    it "includes active inquiries" do
      FactoryGirl.create(:inquiry_type)
      inquiry = FactoryGirl.create(:inquiry)
      Inquiry.list.should_not be_empty 
    end
  end

  describe "should find correct user name" do 
    it { @inquiry.user_name.should_not be_nil } 
  end

  describe "should not find correct user name" do 
    before { @inquiry = @user.inquiries.build FactoryGirl.attributes_for :inquiry, first_name: nil }
    it { @inquiry.user_name.should be_nil } 
  end

  describe ".subject" do 
    it "finds correct subject" do
      FactoryGirl.create(:inquiry_type)
      inquiry = FactoryGirl.build(:inquiry)
      inquiry.subject.should == "Website"  
    end

    it { @inquiry.subject.should be_nil } 
  end

  describe ".contact_type" do 
    it "finds correct contact_type" do
      inquiry = FactoryGirl.build(:inquiry, code: 'XX')
      inquiry.contact_type.should be_nil
    end

    it { @inquiry.contact_type.should == "inquiry" } 
  end

  describe 'set_flds' do
    it "sets status to active" do
      @inquiry = @user.inquiries.build FactoryGirl.attributes_for :inquiry, status: nil
      @inquiry.save
      @inquiry.status.should == 'active'
    end

    it "does not set status to active" do
      @inquiry = @user.inquiries.build FactoryGirl.attributes_for :inquiry, status: 'inactive'
      @inquiry.save
      @inquiry.status.should_not == 'active'
    end
  end

  describe 'is_support?' do
    it 'should not return true' do
      @inquiry.is_support?.should_not be_true
    end

    it 'should return true' do
      inq_type = FactoryGirl.create :inquiry_type, contact_type: 'support', code: 'CD'
      inquiry = FactoryGirl.create :inquiry, code: inq_type.code
      inquiry.is_support?.should be_true
    end
  end

  describe "get_by_status" do
    before { @inquiry.save }
    it { Inquiry.get_by_status('active').should include (@inquiry) }
    it { Inquiry.get_by_status('inactive').should_not include (@inquiry) }
  end

  describe "get_by_contact_type" do
    before { @inquiry.save }
    it { Inquiry.get_by_contact_type('inquiry').should include (@inquiry) }
    it { Inquiry.get_by_contact_type('closed').should_not include (@inquiry) }
  end

end
