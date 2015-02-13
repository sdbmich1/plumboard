require 'spec_helper'
require 'rake'

describe 'import_csv namespace rake task' do
  describe 'import_other_sites' do
    before do
      load File.expand_path("../../../lib/tasks/import_csv.rake", __FILE__)
      Rake::Task.define_task(:environment)
    end

    it 'should import state sites' do
      Rake::Task['import_other_sites'].execute :file_name => "state_site_data_012815.csv", :org_type => "state"
      Site.exists?(name: 'California (statewide)', status: 'active', org_type: 'state').should be_true
      Contact.exists?(address: '1315 10th Street', city: 'Sacramento', state: 'CA', zip: '95814').should be_true
    end

    it 'should import country sites' do
      Rake::Task['import_other_sites'].execute :file_name => "country_site_data_012815.csv", :org_type => "country"
      Site.exists?(name: 'United States', status: 'active', org_type: 'country').should be_true
      Contact.exists?(address: 'East Capitol Street Northeast and First Street Southeast', city: 'Washington', state: 'D.C.', zip: '20004').should be_true
    end
  end
end