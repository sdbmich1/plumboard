require 'spec_helper'
require 'rake'

describe 'manage_server namespace rake task' do
  describe 'manage_server:close_expired_pixis' do

    before do
      load File.expand_path("../../../lib/tasks/manage_server.rake", __FILE__)
      Rake::Task.define_task(:environment)
    end

    it "should call close_pixis" do
      Listing.should_receive :close_pixis
      Rake::Task["manage_server:close_expired_pixis"].invoke
    end
  end
end