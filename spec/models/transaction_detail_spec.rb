require 'spec_helper'

describe TransactionDetail do
  before(:each) do
    @transaction_detail = FactoryGirl.create(:transaction_detail) 
  end

  it "should have a transactions method" do
    @transaction_detail.should respond_to(:transaction) 
  end

  describe "when transaction_id is empty" do
    before { @transaction_detail.transaction_id = "" }
    it { should_not be_valid }
  end

  describe "when transaction_id is entered" do
    before { @transaction_detail.transaction_id = 1 }
    it { @transaction_detail.transaction_id.should == 1 }
  end

  describe "when item_name is empty" do
    before { @transaction_detail.item_name = "" }
    it { should_not be_valid }
  end

  describe "when item_name is entered" do
    before { @transaction_detail.item_name = "chair" }
    it { @transaction_detail.item_name.should == "chair" }
  end

  describe "when quantity is empty" do
    before { @transaction_detail.quantity = "" }
    it { should_not be_valid }
  end

  describe "when quantity is entered" do
    before { @transaction_detail.quantity = 1 }
    it { @transaction_detail.quantity.should == 1 }
  end

  describe "when price is empty" do
    before { @transaction_detail.price = "" }
    it { should_not be_valid }
  end

  describe "when price is entered" do
    before { @transaction_detail.price = 1.00 }
    it { @transaction_detail.price.should == 1.00 }
  end

end
