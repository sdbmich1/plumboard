require 'spec_helper'

describe PixiWant do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user) 
    @category = FactoryGirl.create(:category, pixi_type: 'premium') 
    @listing = FactoryGirl.create(:listing, seller_id: @user.id) 
    @pixi_want = @user.pixi_wants.build FactoryGirl.attributes_for :pixi_want, pixi_id: @listing.pixi_id, status: 'active'
  end

  subject { @pixi_want }

  it { is_expected.to respond_to(:pixi_id) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:quantity) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:fulfillment_type_code) }
  it { is_expected.to respond_to(:user) }
  it { is_expected.to respond_to(:listing) }
  it { is_expected.to validate_presence_of(:pixi_id) }
  it { is_expected.to belong_to(:listing).with_foreign_key('pixi_id') }
  it { is_expected.to belong_to(:user) }

  describe "user name" do 
    it { expect(@pixi_want.user_name).to eq(@user.name) } 

    it "does not find user name" do 
      @pixi_want.user_id = 100
      @pixi_want.save
      @pixi_want.reload
      expect(@pixi_want.user_name).to be_nil  
    end
  end

  describe "get_by_status" do 
    it { expect(PixiWant.get_by_status('active')).to be_empty }
    it "includes active wants" do  
      @pixi_want.save
      expect(PixiWant.get_by_status('active')).not_to be_empty 
    end
  end

  describe "set_status" do
    before { @pixi_want.save }
    it { expect(PixiWant.set_status(nil, @user.id, 'active')).not_to eq(1) }
    it { expect(PixiWant.set_status(@listing.pixi_id, @user.id, 'sold')).to eq(1) }
  end
end
