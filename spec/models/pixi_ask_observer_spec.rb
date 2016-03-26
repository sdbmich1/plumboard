require 'spec_helper'

describe PixiAskObserver do
  describe 'after_create' do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:buyer) { FactoryGirl.create :pixi_user }
    let(:listing) { FactoryGirl.create :listing, seller_id: user.id }
    let(:pixi_ask) { buyer.pixi_asks.build FactoryGirl.attributes_for :pixi_ask, pixi_id: listing.pixi_id }

    it 'should deliver the receipt' do
      @user_mailer = double(UserMailer)
      expect(UserMailer).to receive(:ask_question).with(pixi_ask).and_return(@user_mailer)
      expect(@user_mailer).to receive(:deliver_later)
      pixi_ask.save!
    end

    it 'marks saved pixis as asked' do
      expect {
        create(:saved_listing, user_id: buyer.id, pixi_id: listing.pixi_id); sleep 2
        create(:pixi_ask, pixi_id: listing.pixi_id, user_id: buyer.id); sleep 2
      }.to change{ SavedListing.where(:status => 'asked').count }.by(1)
    end

    it 'should add pixi points' do
      pixi_ask.save!
      expect(buyer.user_pixi_points.find_by_code('cs').code).to eq('cs')
    end
  end
end

