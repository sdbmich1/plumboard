require 'spec_helper'

describe Contact do
  before(:each) do
    @contact = FactoryGirl.build(:contact) 
  end

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
