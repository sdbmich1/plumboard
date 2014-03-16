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
  it { should respond_to(:county) }
  it { should respond_to(:work_phone) }
  it { should respond_to(:home_phone) }
  it { should respond_to(:mobile_phone) }
  it { should respond_to(:website) }
  it { should respond_to(:country) }
  it { should respond_to(:lng) }
  it { should respond_to(:lat) }
  it { should respond_to(:contactable) }
  it { should ensure_length_of(:zip).is_equal_to(5) }
  it { should ensure_length_of(:home_phone).is_equal_to(10) }
  it { should ensure_length_of(:mobile_phone).is_equal_to(10) }
  it { should ensure_length_of(:work_phone).is_equal_to(10) }

  it { should allow_value(4157251111).for(:home_phone) }
  it { should allow_value(4157251111).for(:work_phone) }
  it { should allow_value(4157251111).for(:mobile_phone) }
  it { should_not allow_value(7251111).for(:home_phone) }
  it { should_not allow_value(7251111).for(:work_phone) }
  it { should_not allow_value(7251111).for(:mobile_phone) }
  it { should allow_value(41572).for(:zip) }
  it { should_not allow_value(725).for(:zip) }

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

  it "has full address" do
    @contact.full_address.should == [@contact.address, @contact.city, @contact.state, @contact.country].compact.join(', ')
  end

end
