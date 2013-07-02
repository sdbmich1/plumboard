require 'spec_helper'

describe PostObserver do
  describe 'after_create' do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:recipient) { FactoryGirl.create :pixi_user, first_name: 'Julia', last_name: 'Child', email: 'jchild@pixitest.com' }
    let(:listing) { FactoryGirl.create :listing, seller_id: user.id }

    it 'should add pixi points' do
      listing.posts.create(content: "Lorem ipsum", user_id: user.id, recipient_id: recipient.id)
      user.user_pixi_points.find_by_code('cs').code.should == 'cs'
    end
  end
end
