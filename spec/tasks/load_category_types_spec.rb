require 'spec_helper'
require 'rake'

describe 'rake task' do
	describe 'load_category_types' do 
		before do
			load File.expand_path("../../../lib/tasks/import_csv.rake", __FILE__)
			Rake::Task.define_task(:environment)
		end

		it "should call load_category_types" do
			Rake::Task["load_category_types"].invoke
			CategoryType.exists?(code: 'sales').should be_true
			CategoryType.exists?(code: 'service').should be_true
			CategoryType.exists?(code: 'event').should be_true
			CategoryType.exists?(code: 'asset').should be_true
			CategoryType.exists?(code: 'vehicle').should be_true
			CategoryType.exists?(code: 'employment').should be_true
		end 
	end
end