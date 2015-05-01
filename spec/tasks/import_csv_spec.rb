require 'spec_helper'
require 'rake'

describe 'import_csv' do
  before :all do
    load File.expand_path("../../../lib/tasks/import_csv.rake", __FILE__)
    Rake::Task.define_task(:environment)
  end

  describe 'import_other_sites' do
    it_behaves_like("import_csv", "import_other_sites", {file_name: "state_site_data_012815.csv", org_type: "state"}, Site,
      {name: 'California (statewide)', status: 'active', org_type: 'state'})

    it_behaves_like("import_csv", "import_other_sites", {file_name: "state_site_data_012815.csv", org_type: "state"}, Contact,
      {address: '1315 10th Street', city: 'Sacramento', state: 'CA', zip: '95814'})

    it_behaves_like("import_csv", "import_other_sites", {file_name: "country_site_data_012815.csv", org_type: "country"}, Site,
      {name: 'United States', status: 'active', org_type: 'country'})

    it_behaves_like("import_csv", "import_other_sites", {file_name: "country_site_data_012815.csv", org_type: "country"}, Contact,
      {address: 'East Capitol Street Northeast and First Street Southeast', city: 'Washington', state: 'D.C.', zip: '20004'})
  end

  describe 'load_category_types' do 
    it_behaves_like("import_csv", "load_category_types", nil, CategoryType, { code: %w(sales service event asset vehicle employment) })
  end

  describe 'load_condition_types' do
    it_behaves_like("import_csv", "load_condition_types", nil, ConditionType,
      {code: %w(N RF ULN UVG UG), description: 'New', status: 'active', hide: %w(no yes)})
  end

  describe "load_event_types" do
    it_behaves_like("import_csv", "load_event_types", nil, EventType, { code: %w(session fund art) })
  end

  describe 'load_feeds' do
    before do
      # Need regions in order to assign site id
      load File.expand_path("../../../lib/tasks/import_csv.rake", __FILE__)
      Rake::Task.define_task(:environment)
      Rake::Task["load_regions"].invoke
    end
    it_behaves_like("import_csv", "load_feeds", nil, Feed,
      { site_name: 'SF Bay Area', description: 'SF Examiner', url: 'http://www.sfexaminer.com/sanfrancisco/Rss.xml?section=2124643' })
  end

  describe "load_fulfillment_types" do
    it_behaves_like("import_csv", "load_fulfillment_types", nil, FulfillmentType,
      { code: %w(SHP D M P), description: %w(Ship Delivery Meetup Pickup), status: 'active', hide: %w(no yes) })
  end

  describe 'load_status_types' do
    it_behaves_like("import_csv", "load_status_types", nil, StatusType,
      { code: %w(pending active draft expired sold removed denied invoiced wanted), hide: 'yes' })
  end
end