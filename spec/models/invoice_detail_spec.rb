require 'spec_helper'

describe InvoiceDetail do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user, email: "jblow123@pixitest.com") 
    @buyer = FactoryGirl.create(:pixi_user, first_name: 'Jaine', last_name: 'Smith', email: 'jaine.smith@pixitest.com') 
    @listing = FactoryGirl.create(:listing, seller_id: @user.id)
    @invoice = @user.invoices.build FactoryGirl.attributes_for(:invoice, buyer_id: @buyer.id)
    @details = @invoice.invoice_details.build pixi_id: @listing.pixi_id 
  end

  subject { @details }

  it { should respond_to(:invoice_id) }
  it { should respond_to(:pixi_id) }
  it { should respond_to(:price) }
  it { should respond_to(:quantity) }
  it { should respond_to(:subtotal) }
  it { should belong_to(:invoice) }
  it { should belong_to(:listing).with_foreign_key('pixi_id') }
  it { should validate_presence_of(:pixi_id) }
  it { should validate_presence_of(:price) }
  it { should validate_presence_of(:quantity) }
  it { should validate_presence_of(:subtotal) }
  it { should allow_value(50.00).for(:price) }
  it { should allow_value(5000).for(:price) }
  it { should_not allow_value('').for(:price) }
  it { should_not allow_value(50000000).for(:price) }
  it { should_not allow_value(5000.001).for(:price) }
  it { should_not allow_value(-5000.00).for(:price) }
  it { should_not allow_value('$5000.0').for(:price) }
  it { should allow_value(1).for(:quantity) }
  it { should allow_value(50).for(:quantity) }
  it { should_not allow_value('').for(:quantity) }
  it { should_not allow_value(5000).for(:quantity) }
  it { should allow_value(50).for(:subtotal) }
  it { should_not allow_value('').for(:subtotal) }
  it { should_not allow_value(0).for(:subtotal) }
  it { should_not allow_value(-5000.00).for(:subtotal) }

  describe 'pixi_title' do
    it "has a title", run: true do
      @details.pixi_title.should_not be_empty  
    end

    it "should not find correct pixi_title" do 
      @details.pixi_id = '100' 
      @details.pixi_title.should be_nil 
    end
  end
end
