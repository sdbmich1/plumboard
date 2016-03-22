require 'spec_helper'

describe PixiWantObserver do
  describe 'after_create' do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:buyer) { FactoryGirl.create :pixi_user }
    let(:listing) { FactoryGirl.create :listing, seller_id: user.id }
    let(:pixi_want) { buyer.pixi_wants.build FactoryGirl.attributes_for :pixi_want, pixi_id: listing.pixi_id }

    it 'should deliver the receipt' do
      @user_mailer = double(UserMailer)
      expect(UserMailer).to receive(:send_interest).with(pixi_want).and_return(@user_mailer)
      expect(@user_mailer).to receive(:deliver_later)
      pixi_want.save!
    end

    it 'marks saved pixis as wanted' do
      expect {
        create(:saved_listing, user_id: buyer.id, pixi_id: listing.pixi_id); sleep 2
        create(:pixi_want, pixi_id: listing.pixi_id, user_id: buyer.id); sleep 2
      }.to change{ SavedListing.where(:status => 'wanted').count }.by(1)
    end

    it 'should add pixi points' do
      pixi_want.save!
      expect(buyer.user_pixi_points.find_by_code('cs').code).to eq('cs')
    end
  end
end
