require 'spec_helper'

describe ShipAddress do
  before :each do
    @ship_address = ShipAddress.create
  end

  describe 'attributes', base: true do 
    it { should respond_to(:recipient_first_name) }
    it { should respond_to(:recipient_last_name) }
    it { should respond_to(:recipient_email) }
    it { should respond_to(:user_id) }
    it { should belong_to(:user) }
    it { should have_many(:contacts) }
  end

  describe 'recipient_name' do
    it 'returns first and last name' do
      @ship_address.recipient_first_name = 'Test'
      @ship_address.recipient_last_name = 'Name'
      expect(@ship_address.recipient_name).to eq 'Test Name'
    end
  end
end
