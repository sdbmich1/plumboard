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

  it { is_expected.to respond_to(:invoice_id) }
  it { is_expected.to respond_to(:pixi_id) }
  it { is_expected.to respond_to(:price) }
  it { is_expected.to respond_to(:quantity) }
  it { is_expected.to respond_to(:subtotal) }
  it { is_expected.to respond_to(:fulfillment_type_code) }
  it { is_expected.to belong_to(:invoice) }
  it { is_expected.to belong_to(:listing).with_foreign_key('pixi_id') }
  it { is_expected.to belong_to(:fulfillment_type).with_foreign_key('fulfillment_type_code') }
  it { is_expected.to validate_presence_of(:pixi_id) }
  it { is_expected.to validate_presence_of(:price) }
  it { is_expected.to validate_presence_of(:quantity) }
  it { is_expected.to validate_presence_of(:subtotal) }
  context 'amounts' do
    [['quantity', 99], ['subtotal', 15000], ['price', 15000]].each do |item|
      it_behaves_like 'an amount', item[0], item[1]
    end
  end

  describe 'pixi_title' do
    it "has a title", run: true do
      expect(@details.pixi_title).not_to be_empty  
    end

    it "should not find correct pixi_title" do 
      @details.pixi_id = '100' 
      expect(@details.pixi_title).to be_nil 
    end
  end
end
