require 'spec_helper'

describe CommentObserver do
  describe 'after_create' do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:listing) { FactoryGirl.create :listing, seller_id: user.id }

    it 'should add pixi points' do
      listing.comments.create(content: "Lorem ipsum", user_id: user.id)
      expect(user.user_pixi_points.find_by_code('pc').code).to eq('pc')
    end
  end
end
