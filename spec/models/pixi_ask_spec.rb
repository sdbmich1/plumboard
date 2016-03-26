require 'spec_helper'

describe PixiAsk do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user) 
    @category = FactoryGirl.create(:category, pixi_type: 'premium') 
    @listing = FactoryGirl.create(:listing, seller_id: @user.id) 
    @pixi_ask = @user.pixi_asks.build FactoryGirl.attributes_for :pixi_ask, pixi_id: @listing.pixi_id
  end

  subject { @pixi_ask }

  it { is_expected.to respond_to(:pixi_id) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:user) }
  it { is_expected.to respond_to(:listing) }

  it { is_expected.to validate_presence_of(:pixi_id) }
  it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:pixi_id) }
  it { is_expected.to belong_to(:listing).with_foreign_key('pixi_id') }
  it { is_expected.to belong_to(:user) }

  describe "user name" do 
    it { expect(@pixi_ask.user_name).to eq(@user.name) } 

    it "does not find user name" do 
      @pixi_ask.user_id = 100
      @pixi_ask.save
      @pixi_ask.reload
      expect(@pixi_ask.user_name).to be_nil  
    end
  end
end
