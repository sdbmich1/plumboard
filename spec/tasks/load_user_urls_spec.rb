require 'spec_helper'
require 'rake'

describe 'load_data namespace rake task' do
  describe 'load_user_urls' do
    before do
      load File.expand_path("../../../lib/tasks/load_data.rake", __FILE__)
      Rake::Task.define_task(:environment)
    end

    it 'should load urls' do
      Rake::Task['db:load_user_urls'].execute
      User.exists?(url: nil).should be_false
    end
  end
end
