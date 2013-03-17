require 'spec_helper'

describe TransactionDetail do
  before(:each) do
    @transaction_detail = FactoryGirl.create(:transaction_detail) 
  end

  subject { @transaction_detail }

  it { should respond_to(:transaction)  }
  it { should respond_to(:transaction_id)  }
  it { should respond_to(:item_name)  }
  it { should respond_to(:quantity)  }
  it { should respond_to(:price)  }

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

  describe "when quantity is invalid" do
    before { @transaction_detail.quantity = "a" }
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

  describe "when price is invalid" do
    before { @transaction_detail.price = "a" }
    it { should_not be_valid }
  end

  describe "when price is entered" do
    before { @transaction_detail.price = 1.00 }
    it { @transaction_detail.price.should == 1.00 }
  end

end
