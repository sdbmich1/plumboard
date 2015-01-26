require 'spec_helper'
require 'rake'

describe 'import_csv namespace rake task' do
  describe "load_event_types" do
    before do
      load File.expand_path("../../../lib/tasks/import_csv.rake", __FILE__)
      Rake::Task.define_task(:environment)
    end
        
    it "should call load_event_types" do
      Rake::Task["load_event_types"].invoke
      expect !(EventType.first.nil?)
      EventType.exists?(code: 'session').should be_true
      EventType.exists?(code: 'fund').should be_true
      EventType.exists?(code: 'art').should be_true
    end
  end
end
