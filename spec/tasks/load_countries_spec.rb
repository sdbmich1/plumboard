require 'spec_helper'
require 'rake'

describe 'load_data namespace rake task' do
  describe 'load_countries' do
    before do
      load File.expand_path("../../../lib/tasks/load_data.rake", __FILE__)
      Rake::Task.define_task(:environment)
    end

    it 'should import state sites' do
      Rake::Task['db:load_countries'].execute
      Contact.exists?(country: nil).should be_false
    end
  end
end