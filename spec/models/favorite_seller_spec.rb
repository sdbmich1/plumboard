require 'spec_helper'

describe FavoriteSeller do
  before :each do
    @favorite_seller = create :favorite_seller
  end

  subject { @favorite_seller }
  describe 'attributes', base: true do
    describe '#attributes' do
      subject { super().attributes }
      it { is_expected.to include(*%w(seller_id user_id status)) }
    end
    it { is_expected.to validate_presence_of(:seller_id) }
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe "get_by_status" do
  	it "returns @favorite_seller when found" do
  	  expect(FavoriteSeller.get_by_status("active").first).to eq @favorite_seller
  	end

    it "returns nil otherwise" do
      expect(FavoriteSeller.get_by_status("removed").first).to be_nil
    end
  end

  describe "save" do
    context 'active' do
      it 'fav already exists' do
        fav = FavoriteSeller.save(@favorite_seller.user_id, @favorite_seller.seller_id, 'active')
        expect(fav.status).to eq 'active'
      end
      it 'changes status' do
        fav = FavoriteSeller.save(@favorite_seller.user_id, @favorite_seller.seller_id, 'removed')
        expect(fav.status).to eq 'removed'
      end
      it 'creates new fav' do
        usr = create(:pixi_user)
        biz = create(:business_user)
        fav = FavoriteSeller.save(usr.id, biz.id, 'active')
        expect(fav.status).to eq 'active'
      end
    end
  end
end
