require 'spec_helper'

describe Inquiry do
  before(:each) do
    @user = FactoryGirl.create :pixi_user
    @inq_type = FactoryGirl.create :inquiry_type, contact_type: 'inquiry'
    @inquiry = @user.inquiries.build FactoryGirl.attributes_for(:inquiry, code: @inq_type.code) 
  end
   
  subject { @inquiry } 

  it { is_expected.to respond_to(:comments) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:first_name) }
  it { is_expected.to respond_to(:last_name) }
  it { is_expected.to respond_to(:email) }
  it { is_expected.to respond_to(:code) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:user) }
  it { is_expected.to belong_to(:inquiry_type).with_foreign_key('code') }

  describe "when comments is empty" do
    before { @inquiry.comments = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when comments is not empty" do
    it { is_expected.to be_valid }
  end

  describe "when first_name is empty" do
    before { @inquiry.first_name = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when first_name is invalid" do
    before { @inquiry.first_name = "@@@@" }
    it { is_expected.not_to be_valid }
  end

  describe "when first_name is too long" do
    before { @inquiry.first_name = "a" * 31 }
    it { is_expected.not_to be_valid }
  end

  describe "when last_name is empty" do
    before { @inquiry.last_name = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when last_name is invalid" do
    before { @inquiry.last_name = "@@@" }
    it { is_expected.not_to be_valid }
  end

  describe "when last_name is too long" do
    before { @inquiry.last_name = "a" * 31 }
    it { is_expected.not_to be_valid }
  end

  describe "validations" do

    it "should accept valid work email addresses" do
      addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
      addresses.each do |address|
        @inquiry.email = address
        expect(@inquiry).to be_valid
      end
    end

    it "should reject invalid email addresses" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
      addresses.each do |address|
        @inquiry.email = address
        expect(@inquiry).not_to be_valid
      end
    end
  end

  describe "when comments is empty" do
    before { @inquiry.comments = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when comments is not empty" do
    it { is_expected.to be_valid }
  end

  describe "when code is empty" do
    before { @inquiry.code = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when code is not empty" do
    it { is_expected.to be_valid }
  end

  describe "should include active inquiries" do
    it { expect(Inquiry.active).not_to be_nil }
  end

  describe "should not include inactive inquiries" do
    inquiry = FactoryGirl.create(:inquiry, :status=>'inactive')
    it { expect(Inquiry.active).not_to include (inquiry) } 
  end

  describe ".list" do
    it { expect(Inquiry.list).to be_empty }

    it "includes active inquiries" do
      FactoryGirl.create(:inquiry_type)
      inquiry = FactoryGirl.create(:inquiry)
      expect(Inquiry.list).not_to be_empty 
    end
  end

  describe "should find correct user name" do 
    it { expect(@inquiry.user_name).not_to be_nil } 
  end

  describe "should not find correct user name" do 
    before { @inquiry = @user.inquiries.build FactoryGirl.attributes_for :inquiry, first_name: nil }
    it { expect(@inquiry.user_name).to be_nil } 
  end

  describe ".subject" do 
    it "finds correct subject" do
      FactoryGirl.create(:inquiry_type)
      inquiry = FactoryGirl.build(:inquiry)
      expect(inquiry.subject).to eq("Website")  
    end

    it { expect(@inquiry.subject).to be_nil } 
  end

  describe ".contact_type" do 
    it "finds correct contact_type" do
      inquiry = FactoryGirl.build(:inquiry, code: 'XX')
      expect(inquiry.contact_type).to be_nil
    end

    it { expect(@inquiry.contact_type).to eq("inquiry") } 
  end

  describe 'set_flds' do
    it "sets status to active" do
      @inquiry = @user.inquiries.build FactoryGirl.attributes_for :inquiry, status: nil
      @inquiry.save
      expect(@inquiry.status).to eq('active')
    end

    it "does not set status to active" do
      @inquiry = @user.inquiries.build FactoryGirl.attributes_for :inquiry, status: 'inactive'
      @inquiry.save
      expect(@inquiry.status).not_to eq('active')
    end
  end

  describe 'is_support?' do
    it 'should not return true' do
      expect(@inquiry.is_support?).not_to be_truthy
    end

    it 'should return true' do
      inq_type = FactoryGirl.create :inquiry_type, contact_type: 'support', code: 'CD'
      inquiry = FactoryGirl.create :inquiry, code: inq_type.code
      expect(inquiry.is_support?).to be_truthy
    end
  end

  describe "get_by_status" do
    before { @inquiry.save }
    it { expect(Inquiry.get_by_status('active')).to include (@inquiry) }
    it { expect(Inquiry.get_by_status('inactive')).not_to include (@inquiry) }
  end

  describe "get_by_contact_type" do
    before { @inquiry.save }
    it { expect(Inquiry.get_by_contact_type('inquiry')).to include (@inquiry) }
    it { expect(Inquiry.get_by_contact_type('closed')).not_to include (@inquiry) }
  end

end
