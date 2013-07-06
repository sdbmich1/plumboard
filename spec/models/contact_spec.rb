require 'spec_helper'

describe Contact do
  before(:each) do
    @contact = FactoryGirl.build(:contact) 
  end

  it { should respond_to(:address) }
  it { should respond_to(:address2) }
  it { should respond_to(:city) }
  it { should respond_to(:state) }
  it { should respond_to(:zip) }
  it { should respond_to(:work_phone) }
  it { should respond_to(:home_phone) }
  it { should respond_to(:mobile_phone) }
  it { should respond_to(:website) }
  it { should respond_to(:country) }
  it { should respond_to(:lng) }
  it { should respond_to(:lat) }
  it { should respond_to(:contactable) }

  describe "when address is empty" do
    before { @contact.address = "" }
    it { should_not be_valid }
  end

  describe "when city is invalid" do
    before { @contact.city = "@@@@" }
    it { should_not be_valid }
  end

  describe "when city is empty" do
    before { @contact.city = "" }
    it { should_not be_valid }
  end

  describe "when state is empty" do
    before { @contact.state = "" }
    it { should_not be_valid }
  end

  describe "when zip is empty" do
    before { @contact.zip = "" }
    it { should_not be_valid }
  end

end
