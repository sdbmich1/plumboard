require 'spec_helper'

RSpec.describe PromoCodeUser, type: :model do
  before(:each) do
    @user = create(:pixi_user) 
    @promo_code = create(:promo_code)
    @promo_code_user = @user.promo_code_users.build attributes_for :promo_code_user, promo_code_id: @promo_code.id, status: 'active'
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

  describe "get_by_user" do
    before { @promo_code_user.save }
    it { expect(PromoCodeUser.get_by_user(@user.id, 'active').count).to eq(1) }
    it { expect(PromoCodeUser.get_by_user(@user.id, 'used').count).not_to eq(1) }
    it { expect(PromoCodeUser.get_by_user(100, 'active').count).not_to eq(1) }
  end

  describe "save" do
    context 'active' do
      before :each do 
        @usr = create(:pixi_user)
        @biz = create(:business_user)
        @promo_code = create(:promo_code, owner_id: @biz.id)
      end
      it 'pc already exists' do
        @promo_code_user = @usr.promo_code_users.create attributes_for :promo_code_user, promo_code_id: @promo_code.id, status: 'active'
        PromoCodeUser.save(@promo_code.id, @usr.id, 'active')
        expect(PromoCodeUser.all.count).to eq 1
      end
      it 'changes status' do
        @promo_code_user = @usr.promo_code_users.create attributes_for :promo_code_user, promo_code_id: @promo_code.id, status: 'active'
        pc = PromoCodeUser.save(@promo_code.id, @usr.id, 'removed')
        expect(pc.status).to eq 'removed'
      end
      it 'creates new pc' do
        pc = PromoCodeUser.save(@usr.id, @biz.id, 'active')
        expect(pc.status).to eq 'active'
      end
    end
  end
end
