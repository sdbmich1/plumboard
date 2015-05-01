require 'spec_helper'
require 'rake'

describe 'load_data' do
  before :all do
    load File.expand_path("../../../lib/tasks/load_data.rake", __FILE__)
    Rake::Task.define_task(:environment)
  end

  describe 'load_countries' do
    it_behaves_like("import_csv", "db:load_countries", nil, Contact, { country: nil })
  end

  describe 'load_user_urls' do
    it_behaves_like("import_csv", "db:load_user_urls", nil, User, { url: nil })
  end
end