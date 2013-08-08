require 'spec_helper'

describe Invoice do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user, email: "jblow123@pixitest.com") 
    @buyer = FactoryGirl.create(:pixi_user, first_name: 'Jaine', last_name: 'Smith', email: 'jaine.smith@pixitest.com') 
    @listing = FactoryGirl.create(:listing, seller_id: @user.id)
    @account = @user.bank_accounts.create FactoryGirl.attributes_for :bank_account
    @invoice = @user.invoices.build FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @buyer.id)
  end

  subject { @invoice }

  it { should respond_to(:pixi_id) }
  it { should respond_to(:buyer_id) }
  it { should respond_to(:seller_id) }
  it { should respond_to(:transaction_id) }
  it { should respond_to(:price) }
  it { should respond_to(:amount) }
  it { should respond_to(:quantity) }
  it { should respond_to(:sales_tax) }
  it { should respond_to(:comment) }
  it { should respond_to(:tax_total) }
  it { should respond_to(:inv_date) }
  it { should respond_to(:buyer_name) }
  it { should respond_to(:subtotal) }
  it { should respond_to(:bank_account_id) }

  it { should respond_to(:seller) }
  it { should respond_to(:buyer) }
  it { should respond_to(:listing) }
  it { should respond_to(:transaction) }
  it { should respond_to(:posts) }
  it { should respond_to(:bank_account) }
  it { should respond_to(:set_flds) }
  
  describe "when seller_id is empty" do
    before { @invoice.seller_id = "" }
    it { should_not be_valid }
  end

  describe "when seller_id is entered" do
    before { @invoice.seller_id = 1 }
    it { @invoice.seller_id.should == 1 }
  end
  
  describe "when buyer_id is empty" do
    before { @invoice.buyer_id = "" }
    it { should_not be_valid }
  end

  describe "when buyer_id is entered" do
    before { @invoice.buyer_id = 1 }
    it { @invoice.buyer_id.should == 1 }
  end
  
  describe "when pixi_id is empty" do
    before { @invoice.pixi_id = "" }
    it { should_not be_valid }
  end

  describe "when pixi_id is entered" do
    before { @invoice.pixi_id = "1" }
    it { @invoice.pixi_id.should == "1" }
  end

  describe "when price is not a number" do
    before { @invoice.price = "$500" }
    it { should_not be_valid }
  end
  
  describe "when price is a number" do
    before { @invoice.price = 50.00 }
    it { should be_valid }
  end
  
  describe "when price is empty" do
    before { @invoice.price = "" }
    it { should_not be_valid }
  end

  describe "when amount is not a number" do
    before { @invoice.amount = "$500" }
    it { should_not be_valid }
  end
  
  describe "when amount is a number" do
    before { @invoice.amount = 50.00 }
    it { should be_valid }
  end
  
  describe "when amount is empty" do
    before { @invoice.amount = "" }
    it { should_not be_valid }
  end

  describe "when quantity is not a number" do
    before { @invoice.quantity = "$500" }
    it { should_not be_valid }
  end
  
  describe "when quantity is a number" do
    before { @invoice.quantity = 5 }
    it { should be_valid }
  end
  
  describe "when quantity is empty" do
    before { @invoice.quantity = "" }
    it { should_not be_valid }
  end
  
  describe "when quantity is 0" do
    before { @invoice.quantity = 0 }
    it { should_not be_valid }
  end

  describe "when sales_tax is not a number" do
    before { @invoice.sales_tax = "$500" }
    it { should_not be_valid }
  end
  
  describe "when sales_tax is a number" do
    before { @invoice.sales_tax = 5.00 }
    it { should be_valid }
  end

  describe "get_by_status" do 
    before { @invoice.save }
    it { Invoice.get_by_status('unpaid').should_not be_empty }
    it { Invoice.get_by_status('paid').should be_empty }
  end

  describe "get_invoices" do 
    before { @invoice.save }

    it { Invoice.get_invoices(@user).should_not be_empty }
    it { Invoice.get_invoices(@buyer).should be_empty }
  end

  describe "find_invoice" do 
    before { @invoice.save }
    let(:order) { {"cnt"=> 1, "quantity1"=> 1, "item1"=> 'Pixi Post', "price1"=> 75.0, "invoice_id"=> @invoice.id} }
    let(:order2) { {"cnt"=> 1, "quantity1"=> 1, "item1"=> 'Pixi Post', "price1"=> 75.0, "invoice_id"=> ''} }

    it { Invoice.find_invoice(order).should_not be_nil }
    it { Invoice.find_invoice(order2).should be_nil }
  end

  describe "paid" do 
    it "should not verify invoice is paid" do 
      @invoice.paid?.should_not be_true 
    end

    it "should verify invoice is paid" do 
      @invoice.status = 'paid'
      @invoice.paid?.should be_true 
    end
  end

  describe "unpaid" do 
    it "should verify invoice is unpaid" do 
      @invoice.unpaid?.should be_true 
    end

    it "should not verify invoice is unpaid" do 
      @invoice.status = 'paid'
      @invoice.unpaid?.should_not be_true 
    end
  end

  describe "owner" do 
    it "should verify user is owner" do 
      @invoice.owner?(@user).should be_true 
    end

    it "should not verify user is owner" do 
      @invoice.owner?(@buyer).should_not be_true 
    end
  end

  describe 'credit_account' do
    before do
      @account = @user.bank_accounts.create FactoryGirl.attributes_for :bank_account
      @invoice.bank_account_id = @account.id
      @bank_acct = mock('Balanced::BankAccount', :amount=>50000)
      Balanced::BankAccount.stub!(:find).with(@account.token).and_return(@bank_acct)
      @bank_acct.stub!(:credit).and_return(true)
    end

    it "should credit account" do 
      @invoice.credit_account.should be_true
    end

    it "should not credit account" do 
      @invoice.amount = nil
      @invoice.credit_account.should_not be_true 
    end
  end

  describe "transactions" do
    let(:transaction) { FactoryGirl.create :transaction }

    it "does not submit payment" do 
      @invoice.submit_payment(nil).should_not be_true
    end

    it "submits payment" do 
      @invoice.submit_payment(transaction.id).should be_true
    end
  end

  describe "set_flds" do
    it "does not set flds" do 
      invoice = @user.invoices.build FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @buyer.id, status: 'paid')
      invoice.save
      invoice.status.should_not == 'unpaid'
    end

    it "does not set flds" do 
      @invoice.status = nil
      @invoice.save
      @invoice.status.should == 'unpaid'
    end
  end

  describe "buyer" do 
    it { @invoice.buyer_name.should_not be_empty } 

    it "should not find correct buyer name" do 
      @invoice.buyer_id = 100 
      @invoice.buyer_name.should be_nil 
    end
  end

end
