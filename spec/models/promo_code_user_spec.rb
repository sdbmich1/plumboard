require 'spec_helper'

RSpec.describe PromoCodeUser, type: :model do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user) 
    @promo_code = FactoryGirl.create(:promo_code)
    @promo_code_user = @user.promo_code_users.build FactoryGirl.attributes_for :promo_code_user, promo_code_id: @promo_code.id, status: 'active'
  end

  subject { @promo_code_user }

  it { is_expected.to respond_to(:promo_code_id) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:user) }
  it { is_expected.to respond_to(:promo_code) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:promo_code_id) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:promo_code) }

  describe "get_by_status" do 
    it { expect(PromoCodeUser.get_by_status('active')).to be_empty }
    it "includes active codes" do  
      @promo_code_user.save
      expect(PromoCodeUser.get_by_status('active')).not_to be_empty 
    end
  end

  describe "set_status" do
    before { @promo_code_user.save }
    it { expect(PromoCodeUser.set_status(nil, @user.id, 'active')).not_to eq(1) }
    it { expect(PromoCodeUser.set_status(@promo_code.id, @user.id, 'used')).to eq(1) }
  end
end
