require 'spec_helper'
require 'rake'

describe 'manage server namespace rake task' do
  describe 'send_invoiceless_pixi_notices' do
    before do
      load File.expand_path("../../../lib/tasks/manage_server.rake", __FILE__)
      Rake::Task.define_task(:environment)
    end

    it 'should send invoiceless pixi notice' do
      UserMailer.should_receive(:send_invoiceless_pixi_notice).exactly(Listing.invoiceless_pixis.count).times
      Listing.should_receive :invoiceless_pixis
      Rake::Task['manage_server:send_invoiceless_pixi_notices'].invoke
    end
  end
end