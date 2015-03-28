require 'spec_helper'
require 'rake'

describe 'rake task' do
  describe 'load_fulfillment_types' do
    before do
      load File.expand_path("../../../lib/tasks/import_csv.rake", __FILE__)
      Rake::Task.define_task(:environment)
    end

    it "should load fulfillment_types" do
      Rake::Task["load_fulfillment_types"].invoke
      FulfillmentType.exists?(code: 'SHP').should be_true
      FulfillmentType.exists?(code: 'D').should be_true
      FulfillmentType.exists?(code: 'M').should be_true
      FulfillmentType.exists?(code: 'P').should be_true
      FulfillmentType.exists?(description: 'Ship').should be_true
      FulfillmentType.exists?(description: 'Delivery').should be_true
      FulfillmentType.exists?(description: 'Meetup').should be_true
      FulfillmentType.exists?(description: 'Pickup').should be_true
      FulfillmentType.exists?(status: 'active').should be_true
      FulfillmentType.exists?(hide: 'no').should be_true
      FulfillmentType.exists?(hide: 'yes').should be_true
    end
  end
end
