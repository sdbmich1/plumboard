require 'spec_helper'

describe FavoriteSeller do
  before :each do
    @favorite_seller = create :favorite_seller
  end

  subject { @favorite_seller }
  describe 'attributes', base: true do
    its(:attributes) { should include(*%w(seller_id user_id status)) }
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
end
