require 'spec_helper'
require 'rake'

describe 'rake task' do
  describe 'load_condition_types' do
    before do
      load File.expand_path("../../../lib/tasks/import_csv.rake", __FILE__)
      Rake::Task.define_task(:environment)
    end

    it "should load condition_types" do
      Rake::Task["load_condition_types"].invoke
      ConditionType.exists?(code: 'N').should be_true
      ConditionType.exists?(code: 'RF').should be_true
      ConditionType.exists?(code: 'ULN').should be_true
      ConditionType.exists?(code: 'UVG').should be_true
      ConditionType.exists?(code: 'UG').should be_true
      ConditionType.exists?(description: 'New').should be_true
      ConditionType.exists?(status: 'active').should be_true
      ConditionType.exists?(hide: 'no').should be_true
      ConditionType.exists?(hide: 'yes').should be_true
    end
  end
end
