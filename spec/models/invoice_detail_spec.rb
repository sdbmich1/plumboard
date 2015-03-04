require 'spec_helper'

describe InvoiceDetail do
  before(:all) do
    @user = create(:pixi_user, email: "jblow123@pixitest.com") 
    @buyer = create(:pixi_user, first_name: 'Jaine', last_name: 'Smith', email: 'jaine.smith@pixitest.com') 
    @listing = create(:listing, seller_id: @user.id)
  end
  before(:each) do
    @invoice = @user.invoices.build attributes_for(:invoice, buyer_id: @buyer.id)
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
  context 'amounts' do
    [['quantity', 99], ['subtotal', 15000], ['price', 15000]].each do |item|
      it_behaves_like 'an amount', item[0], item[1]
    end
  end

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
