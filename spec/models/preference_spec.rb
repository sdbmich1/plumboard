require 'spec_helper'

describe Preference do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user) 
    @preference = @user.preferences.build FactoryGirl.attributes_for(:preference) 
    @user.save
  end

  def create_listing
    @listing = @user.listings.create(FactoryGirl.attributes_for :listing)
    @listing.pictures.build(FactoryGirl.attributes_for :picture)
    @listing.save
  end

  subject { @preference }

  it { should respond_to(:user_id) }
  it { should respond_to(:zip) }
  it { should respond_to(:email_msg_flg) }
  it { should respond_to(:mobile_msg_flg) }
  it { should respond_to(:buy_now_flg) }
  it { should respond_to(:fulfillment_type_code) }
  it { should respond_to(:sales_tax) }
  it { should respond_to(:ship_amt) }
  it { should belong_to(:user) }
  it { should belong_to(:fulfillment_type).with_foreign_key('fulfillment_type_code') }
  it { should validate_length_of(:zip).is_equal_to(5) }
  it { should allow_value(41572).for(:zip) }
  it { should_not allow_value(725).for(:zip) }
  it { should_not allow_value('a725').for(:zip) }

  describe 'amount fields' do
    context 'amounts' do
      [['sales_tax', 15], ['ship_amt', 500]].each do |item|
        it_behaves_like 'an amount', item[0], item[1]
      end
    end
  end

  describe 'update_existing_pixis' do
    it 'updates listing to match preference' do
      create_listing
      @listing.fulfillment_type_code = 'A'
      @listing.sales_tax = 5.0
      @listing.est_ship_cost = 10.0
      @listing.save
      @preference.fulfillment_type_code = 'P'
      @preference.sales_tax = 10.0
      @preference.ship_amt = 12.0
      @preference.save
      @listing.reload
      expect(@listing.fulfillment_type_code).to eq 'P'
      expect(@listing.sales_tax).to eq 10.0
      expect(@listing.est_ship_cost).to eq 12.0
    end
  end
end
