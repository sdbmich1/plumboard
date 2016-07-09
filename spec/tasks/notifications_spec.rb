require 'spec_helper'
require 'rake'

describe 'notifications' do
  before :all do
    load File.expand_path("../../../lib/tasks/notifications.rake", __FILE__)
    Rake::Task.define_task(:environment)
  end

  describe 'send_favorite_store_notices' do
    before do
      seller = create :business_user
      user = create :pixi_user
      other_user = create :pixi_user
      device = create :device, user_id: user.id, token: 'abcd'
      other_device = create :device, user_id: other_user.id, token: 'efgh'
      create :favorite_seller, user_id: user.id, seller_id: seller.id
      listing = create :listing, seller_id: seller.id
    end

    it_behaves_like 'manage_server', 'msg:send_favorite_store_notices', nil, Pushwoosh, 'notify_devices'
  end
end
