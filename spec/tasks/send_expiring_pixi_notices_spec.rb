require 'spec_helper'
require 'rake'

describe 'manage_server namespace rake task' do
  describe 'manage_server:send_expiring_pixi_notices' do

    before do
      load File.expand_path("../../../lib/tasks/manage_server.rake", __FILE__)
      Rake::Task.define_task(:environment)
    end

    it "should send expiring pixi notice" do
      Listing.should_receive :soon_expiring_pixis
      Rake::Task["manage_server:send_expiring_pixi_notices"].invoke(7)
    end
  end
end