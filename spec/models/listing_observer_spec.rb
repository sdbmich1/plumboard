require 'spec_helper'

describe ListingObserver do
  describe 'after_create' do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:category) { FactoryGirl.create :category }

    it 'should add abp pixi points' do
      listing = FactoryGirl.create(:listing, seller_id: user.id)
      user.user_pixi_points.find_by_code('abp').code.should == 'abp'
    end

    it 'should add app pixi points' do
      @category = FactoryGirl.create(:category, pixi_type: 'premium')
      listing = FactoryGirl.create(:listing, category_id: @category.id, seller_id: user.id)
      user.user_pixi_points.find_by_code('app').code.should == 'app'
    end
  end
end
