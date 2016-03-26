require 'spec_helper'

describe TransactionDetail do
  before(:each) do
    @transaction_detail = FactoryGirl.create(:transaction_detail) 
  end

  subject { @transaction_detail }

  it { is_expected.to respond_to(:transaction)  }
  it { is_expected.to respond_to(:transaction_id)  }
  it { is_expected.to respond_to(:item_name)  }
  it { is_expected.to respond_to(:quantity)  }
  it { is_expected.to respond_to(:price)  }

  describe "when transaction_id is entered" do
    before { @transaction_detail.transaction_id = 1 }
    it { expect(@transaction_detail.transaction_id).to eq(1) }
  end

  describe "when item_name is empty" do
    before { @transaction_detail.item_name = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when item_name is entered" do
    before { @transaction_detail.item_name = "chair" }
    it { expect(@transaction_detail.item_name).to eq("chair") }
  end

  describe "when quantity is empty" do
    before { @transaction_detail.quantity = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when quantity is invalid" do
    before { @transaction_detail.quantity = "a" }
    it { is_expected.not_to be_valid }
  end

  describe "when quantity is entered" do
    before { @transaction_detail.quantity = 1 }
    it { expect(@transaction_detail.quantity).to eq(1) }
  end

  describe "when price is empty" do
    before { @transaction_detail.price = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when price is invalid" do
    before { @transaction_detail.price = "a" }
    it { is_expected.not_to be_valid }
  end

  describe "when price is entered" do
    before { @transaction_detail.price = 1.00 }
    it { expect(@transaction_detail.price).to eq(1.00) }
  end

end
