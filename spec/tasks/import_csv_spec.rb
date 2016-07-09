require 'spec_helper'
require 'rake'

describe 'import_csv' do
  before :all do
    load File.expand_path("../../../lib/tasks/import_csv.rake", __FILE__)
    Rake::Task.define_task(:environment)
  end

  describe 'import_other_sites' do
    it_behaves_like("import_csv", "import_other_sites", {file_name: "state_site_data_012815.csv", site_type_code: "state"}, Site,
      {name: 'California (statewide)', status: 'active', site_type_code: 'state'})

    it_behaves_like("import_csv", "import_other_sites", {file_name: "state_site_data_012815.csv", site_type_code: "state"}, Contact,
      {address: '1315 10th Street', city: 'Sacramento', state: 'CA', zip: '95814'})

    it_behaves_like("import_csv", "import_other_sites", {file_name: "country_site_data_012815.csv", site_type_code: "country"}, Site,
      {name: 'United States', status: 'active', site_type_code: 'country'})

    it_behaves_like("import_csv", "import_other_sites", {file_name: "country_site_data_012815.csv", site_type_code: "country"}, Contact,
      {address: 'East Capitol Street Northeast and First Street Southeast', city: 'Washington', state: 'D.C.', zip: '20004'})
  end

  describe 'load_category_types' do 
    it_behaves_like("import_csv", "load_category_types", nil, CategoryType, { code: %w(sales service event asset vehicle employment) })
  end

  describe 'load_condition_types' do
    it_behaves_like("import_csv", "load_condition_types", nil, ConditionType,
      {code: %w(N RF ULN UVG UG), description: ["New", "Refurbished", "Used - Like New", "Used - Very Good", "Used - Good"], status: 'active', hide: %w(no yes)})
  end

  describe 'load_site_type_codes' do
   it_behaves_like("import_csv", "load_site_type_codes", nil, SiteType, {code: %w(region school city area country pub state), description: ["Region", "College/University", "City", "Neighborhood/District", "Nation/Country", "Newspaper/Magazine", "State/Province"], status: 'active'})
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
      { code: %w(SHP D A P SD PS), description: ['Ship', 'Delivery', 'All', 'Pickup', 'Same-Day', 'Pickup & Ship'], status: %w(active inactive), hide: %w(no yes) })
  end

  describe 'load_status_types' do
    it_behaves_like("import_csv", "load_status_types", nil, StatusType,
      { code: %w(pending active draft expired sold removed denied invoiced wanted), hide: 'yes' })
  end

  describe "update_site_images" do

    it "loads images" do
      # Need regions in order to assign their pictures
      load File.expand_path("../../../lib/tasks/import_csv.rake", __FILE__)
      Rake::Task.define_task(:environment)
      Rake::Task["load_regions"].invoke
      Rake::Task[:update_site_images].execute :file_name => "region_image_data_051415.csv"
      expect(Site.find_by_name("SF Bay Area").pictures.first.photo.to_s).to include "San_Francisco.jpg"
    end

    it "loads images" do
      site = create :site, name: "University of California - Berkeley", site_type_code: "school"
      Rake::Task[:update_site_images].execute :file_name => "college_image_data_071915.csv"
      expect(Site.find_by_name("University of California - Berkeley").pictures.first.photo.to_s).to include "UCBerkeley.png"
    end
  end

  describe 'load_currency_types' do
    it_behaves_like("import_csv", "load_currency_types", nil, CurrencyType,
    { code: %w(AED), description: ['United Arab Emirates Dirham'], status: %w(inactive), hide: %w(yes)})
  end

  describe 'load_currency_types' do
    it_behaves_like("import_csv", "load_message_types", nil, MessageType,
      { code: 'welcome', description: 'Welcome', recipient: 'buyer' })
  end

  describe 'load_stock_images' do
    before do
      # Need categories in order to assign category_type_code
      load File.expand_path("../../../lib/tasks/import_csv.rake", __FILE__)
      Rake::Task.define_task(:environment)
      Rake::Task["load_categories"].invoke
    end
    it_behaves_like('import_csv', 'load_stock_images', nil, StockImage,
      { title: 'Programmer / Analyst / Developer / Software / Computer', category_type_code: 'Employment', file_name: 'Computer.jpg' })
  end
end
