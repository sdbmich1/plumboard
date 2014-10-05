
require 'spec_helper'
require 'rake'

describe 'import_csv namespace rake task' do
  describe 'load_status_types' do
    before do
      load File.expand_path("../../../lib/tasks/import_csv.rake", __FILE__)
      Rake::Task.define_task(:environment)
    end

    it "should load status types" do
      Rake::Task["load_status_types"].invoke
      StatusType.exists?(code: 'pending').should be_true
      StatusType.exists?(code: 'active').should be_true
      StatusType.exists?(code: 'draft').should be_true
      StatusType.exists?(code: 'expired').should be_true
      StatusType.exists?(code: 'sold').should be_true
      StatusType.exists?(code: 'removed').should be_true
      StatusType.exists?(code: 'denied').should be_true
      StatusType.exists?(code: 'invoiced').should be_true
      StatusType.exists?(hide: 'yes').should be_true
    end
  end
end