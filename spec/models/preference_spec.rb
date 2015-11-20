require 'spec_helper'

describe Preference do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user) 
    @preference = @user.preferences.build FactoryGirl.attributes_for(:preference) 
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
  it { should ensure_length_of(:zip).is_equal_to(5) }
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
end
